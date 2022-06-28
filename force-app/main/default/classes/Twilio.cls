public with sharing class Twilio {

    @AuraEnabled
    public static Map<String,Object> createRoom() {
        Twilio__mdt twilioParams = getTwilioParams();
        checkParam(twilioParams);

        String body = 'StatusCallback=' + twilioParams.StatusCallback__c +
            '&Type=' + twilioParams.Type__c +
            '&UniqueName=' + generateRamdomString(twilioParams.Room_Number__c);

        HttpResponse response = sendRequest(
            'POST',
            'callout:Twilio_Credential',
            twilioParams.Version__c,
            body
        );
        checkResponseStatus(response.getStatusCode(), response.getBody());

        Map<String,Object> data = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        return new Map<String,String>{
            'sid' => (String) data.get('sid'),
            'unique_name' => (String) data.get('unique_name')
        };
    }

    @AuraEnabled
    public static String sendMessageToCustomerAndGetLog(String whatId, String roomNumber) {
        checkParam(whatId);
        checkParam(roomNumber);

        Case currentCase = selectCaseById(whatId);
        checkContact(currentCase.ContactId);
        checkContactMobilePhone(currentCase.Contact.MobilePhone);
        Twilio__mdt twilioParams = getTwilioParams();

        try {
            Task newTask = createTask(whatId, roomNumber, currentCase, twilioParams.Message__c);
            insert newTask;
            Twilio_Video_Log__c log = createVideoCallLog(currentCase.ContactId, roomNumber);
            insert log;
            newTask.Twilio_Video_Log__c = log.Id;
            update newTask;
            return log.Id;
        } catch (DmlException e) {
            throw new TwilioException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static void updateVideoCallDate(String logId, String roomSid) {
        checkParam(logId);
        checkParam(roomSid);

        if (getRoomStatus(roomSid) == 'completed') {
            setDisconnectionVideoLog(logId);
            throw new TwilioException('The video session has been already completed, please, create a room again');
        }

        try {
            update new Twilio_Video_Log__c(
                Id = logId,
                Start_Date__c = DateTime.now(),
                End_Date__c = DateTime.now().addMinutes(20)
            );
        } catch (DmlException e) {
            throw new TwilioException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static void closeRoomSession(String logId, String roomSid) {
        checkParam(logId);
        checkParam(roomSid);

        if (getRoomStatus(roomSid) != 'completed') {
            setCompletedVideoRoom(roomSid);
        }

        Twilio_Video_Log__c log = getTwilioVideoLogById(logId);
        if (log.Start_Date__c != null) {
            log.End_Date__c = DateTime.now();
            try {
                update log;
            } catch (DmlException e) {
                throw new TwilioException(e.getDmlMessage(0));
            }
        }
    }

    public static String getRoomStatus(String sid) {
        checkParam(sid);

        Twilio__mdt twilioParams = getTwilioParams();
        checkParam(twilioParams);

        HttpResponse response = sendRequest(
            'GET',
            'callout:Twilio_Credential/' + sid,
            twilioParams.Version__c,
            null
        );
        checkResponseStatus(response.getStatusCode(), response.getBody());

        Map<String,Object> data = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        return (String) data.get('status');
    }

    private static HttpResponse sendRequest(String method, String endPoint, String version, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setMethod(method);
        request.setEndpoint(endPoint);
        request.setHeader('X-Twilio-Client', 'salesforce-' + version);
        request.setHeader('User-Agent', 'twilio-salesforce/' + version);
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Accept-Charset', 'utf-8');
        if (body != null) {
            request.setBody(body);
        }

        return http.send(request);
    }

    private static void setDisconnectionVideoLog(String logId) {
        try {
            update new Twilio_Video_Log__c(
                Id = logId,
                Timeout_disconnection__c = true
            );
        } catch (DmlException e) {
            throw new TwilioException(e.getDmlMessage(0));
        }
    }

    private static void setCompletedVideoRoom(String roomSid) {
        Twilio__mdt twilioParams = getTwilioParams();
        checkParam(twilioParams);

        String body = 'Status=completed';

        HttpResponse response = sendRequest(
            'POST',
            'callout:Twilio_Credential/' + roomSid,
            twilioParams.Version__c,
            body
        );
        checkResponseStatus(response.getStatusCode(), response.getBody());
    }

    private static Twilio_Video_Log__c createVideoCallLog(String contactId, String roomNumber) {
        return new Twilio_Video_Log__c(
            Send_the_request_to_the_Customer__c = DateTime.now(),
            Agent_Name__c = UserInfo.getUserId(),
            Contact_Name__c = contactId,
            Room_Number__c = roomNumber
        );
    }

    private static Task createTask(String whatId, String roomNumber, Case currentCase, String message) {
        String currentAgentName = findCurrentAgentName();
        List<String> messageParams = new List<String>{
            currentCase.Contact.FirstName,
            currentCase.Contact.LastName,
            roomNumber,
            currentAgentName
        };
        return new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS_Task').getRecordTypeId(),
            WhatId = whatId,
            Subject = 'Twilio Communication',
            Description = String.format(message, messageParams),
            Send_SMS__c = true,
            Recipient_Phone_Number__c = currentCase.Contact.MobilePhone
        );
    }
    
    private static String findCurrentAgentName() {
        User currentAgent = getUserById(UserInfo.getUserId());
        return String.isNotBlank(currentAgent.Hebrew_Name__c)
            ? (currentAgent.Hebrew_Name__c).trim()
            : UserInfo.getName();
    }

    private static Case selectCaseById(String caseId) {
        try {
            Case currentCase = [
                SELECT ContactId, Contact.FirstName, Contact.LastName, Contact.MobilePhone
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];
            return currentCase;
        } catch (QueryException e) {
            throw new TwilioException(e.getMessage());
        }
    }

    private static Twilio_Video_Log__c getTwilioVideoLogById(String logId) {
        try {
            Twilio_Video_Log__c log = [
                SELECT Id, Start_Date__c
                FROM Twilio_Video_Log__c
                WHERE Id = :logId
                LIMIT 1
            ];
            return log;
        } catch (QueryException e) {
            throw new TwilioException(e.getMessage());
        }
    }
    
    private static User getUserById(String userId) {
        try {
            User user = [
                SELECT Hebrew_Name__c
                FROM User
                WHERE Id = :userId
                LIMIT 1
            ];
            return user;
        } catch (QueryException e) {
            throw new TwilioException(e.getMessage());
        }
    }

    private static Twilio__mdt getTwilioParams() {
        return Twilio__mdt.getInstance('Twilio_Params');
    }

    private static String generateRamdomString(String chars) {
        String randomString = '';
        while (randomString.length() < 6) {
	        Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(index, index + 1);
        }
        return randomString;
    }

    private static void checkContactMobilePhone(String mobilePhone) {
        if (mobilePhone == null) {
            throw new TwilioException('Please, fill Mobile phone field for Contact');
        }
    }

    private static void checkContact(String contactId) {
        if (contactId == null) {
            throw new TwilioException('Please, fill Contact field for Case');
        }
    }

    private static void checkResponseStatus(Integer statusCode, String body) {
        if (statusCode < 200 || statusCode >= 300) {
            Map<String,Object> data = (Map<String,Object>) JSON.deserializeUntyped(body);
            throw new TwilioException((String) data.get('message'));
        }
    }

    private static void checkParam(Object param) {
        if (param == null) {
            throw new TwilioException('Parameter equals null');
        }
    }

    public class TwilioException extends Exception {}
}
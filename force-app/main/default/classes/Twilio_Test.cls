@isTest
private class Twilio_Test {

    private static String ROOM_NUMBER = 'RM0db30e9';
    private static String COMPLETED_ERROR_MESSAGE = 'The video session has been already completed, please, create a room again';

    @testSetup
    static void setup() {
        Contact contact = new Contact(
            LastName = 'Contact',
            MobilePhone = '054307336'
        );
        insert contact;

        Case testCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId(),
            Case_Type__c = 'Proactive',
            Case_Sub_Type__c = 'Remote Coach',
            Channel__c = 'Inbound',
            ContactId = contact.Id
        );
        insert testCase;

        Twilio_Video_Log__c log = new Twilio_Video_Log__c(
            Agent_Name__c = UserInfo.getUserId(),
            Contact_Name__c = testCase.ContactId,
            Room_Number__c = ROOM_NUMBER,
            Start_Date__c = DateTime.now()
        );
        insert log;

        Task task = new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS_Task').getRecordTypeId(),
            WhatId = testCase.Id,
            Subject = 'Twilio Communication',
            Description = 'Dear ' + contact.FirstName + ', ' +
            contact.LastName + ' please open the link:\r\n' +
            'https://video-app-8273-dev.twil.io?passcode=6150518273\r\n' +
            'Your room number is: ' + ROOM_NUMBER + '\r\n\r\n' +
            'Thanks\r\n' + UserInfo.getFirstName(),
            Send_SMS__c = true,
            Recipient_Phone_Number__c = contact.MobilePhone,
            Twilio_Video_Log__c = log.Id
        );
        insert task;
    }

    @isTest
    static void createRoom_test() {
        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMock());

        Test.startTest();
        Map<String,Object> result = Twilio.createRoom();
        Test.stopTest();

        System.assertEquals(result.get('sid'), ROOM_NUMBER);
        System.assertEquals(result.get('unique_name'), ROOM_NUMBER);
    }

    @isTest
    static void sendMessageToCustomerAndGetLog_test() {
        Case testCase = [
            SELECT Id, ContactId, Contact.MobilePhone
            FROM Case
            LIMIT 1
        ];
        Integer countTask = [SELECT COUNT() FROM Task WHERE WhatId = :testCase.Id];
        Integer countLogs = [SELECT COUNT() FROM Twilio_Video_Log__c WHERE Contact_Name__c = :testCase.ContactId];

        Test.startTest();
        Twilio.sendMessageToCustomerAndGetLog(testCase.Id, ROOM_NUMBER);
        Test.stopTest();

        Integer countTaskResult = [SELECT COUNT() FROM Task WHERE WhatId = :testCase.Id];
        Integer countLogsResult = [SELECT COUNT() FROM Twilio_Video_Log__c WHERE Contact_Name__c = :testCase.ContactId];
        Task task = [
            SELECT Id, Recipient_Phone_Number__c, Twilio_Video_Log__r.Agent_Name__c,
                Twilio_Video_Log__r.Contact_Name__c, Twilio_Video_Log__r.Room_Number__c
            FROM Task
            WHERE WhatId = :testCase.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        System.assertEquals(countTask + 1, countTaskResult);
        System.assertEquals(testCase.Contact.MobilePhone, task.Recipient_Phone_Number__c);

        System.assertEquals(countLogs + 1, countLogsResult);
        System.assertEquals(task.Twilio_Video_Log__r.Agent_Name__c, UserInfo.getUserId());
        System.assertEquals(task.Twilio_Video_Log__r.Contact_Name__c, testCase.ContactId);
        System.assertEquals(task.Twilio_Video_Log__r.Room_Number__c, ROOM_NUMBER);
    }

    @isTest
    static void updateVideoCallDate_test() {
        Twilio_Video_Log__c log = [
            SELECT Id, Start_Date__c, End_Date__c
            FROM Twilio_Video_Log__c
            LIMIT 1
        ];

        TwilioHttpCalloutMock mock = new TwilioHttpCalloutMock();
        mock.status = 'in-progress';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        Twilio.updateVideoCallDate(log.Id, ROOM_NUMBER);
        Test.stopTest();

        Twilio_Video_Log__c logResult = [
            SELECT Id, Start_Date__c, End_Date__c
            FROM Twilio_Video_Log__c
            LIMIT 1
        ];

        System.assertNotEquals(logResult.Start_Date__c, null);
        System.assertNotEquals(logResult.End_Date__c, null);
    }

    @isTest
    static void updateVideoCallDate_completedRoom_test() {
        Twilio_Video_Log__c log = [
            SELECT Id
            FROM Twilio_Video_Log__c
            LIMIT 1
        ];

        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMock());

        Test.startTest();
        try {
            Twilio.updateVideoCallDate(log.Id, ROOM_NUMBER);
        } catch (Exception e) {
            Twilio_Video_Log__c logResult = [
                SELECT Id, Timeout_disconnection__c
                FROM Twilio_Video_Log__c
                WHERE Id = :log.Id
                LIMIT 1
            ];
            System.assertEquals(logResult.Timeout_disconnection__c, true);
            System.assertEquals(e.getMessage(), COMPLETED_ERROR_MESSAGE);
        }
        Test.stopTest();
    }

    @isTest
    static void closeRoomSession_test() {
        Twilio_Video_Log__c log = [
            SELECT Id
            FROM Twilio_Video_Log__c
            LIMIT 1
        ];
        TwilioHttpCalloutMock mock = new TwilioHttpCalloutMock();
        mock.status = 'in-progress';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        Twilio.closeRoomSession(log.Id, ROOM_NUMBER);
        Test.stopTest();

        Twilio_Video_Log__c logResult = [
            SELECT Id, End_Date__c
            FROM Twilio_Video_Log__c
            LIMIT 1
        ];

        System.assertNotEquals(logResult.End_Date__c, null);
    }

    @isTest
    static void getRoomStatus_test() {
        Test.setMock(HttpCalloutMock.class, new TwilioHttpCalloutMock());

        Test.startTest();
        String result = Twilio.getRoomStatus(ROOM_NUMBER);
        Test.stopTest();

        System.assertEquals(result, 'completed');
    }

}
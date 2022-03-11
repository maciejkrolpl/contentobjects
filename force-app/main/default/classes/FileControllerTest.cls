@IsTest
public class FileControllerTest{
    private static final String ACCOUNT_NAME = 'TestAccount';
    private static final String LIBRARY_NAME = 'TestWorkspace';
    private static final String ADMIN_PERMISSION_TYPE = 'Admin';
    private static final String ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String ADMIN_LASTNAME = 'Adminowski';
    @TestSetup
    static void makeData(){
        Profile adminProfile = [SELECT Id
                                FROM Profile
                                WHERE Name = :ADMIN_PROFILE_NAME];
        User admin = new User(
            Email = 'sysadmin@test.eu', 
            ProfileId = adminProfile.Id, 
            UserName = 'sysadmin@test.eu.test', 
            LastName = ADMIN_LASTNAME, 
            Alias = 'admin22', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US');
        insert admin;

        ContentWorkspace workspace = new ContentWorkspace(
            Name = LIBRARY_NAME
        );
        insert workspace;

        ContentWorkspacePermission adminPermission = [SELECT Id, Type
                                                      FROM ContentWorkspacePermission
                                                      WHERE Type = :ADMIN_PERMISSION_TYPE];

        ContentWorkspaceMember member = new ContentWorkspaceMember(
            ContentWorkspaceId = workspace.Id, 
            MemberId = admin.Id, 
            ContentWorkspacePermissionId = adminPermission.Id);
        insert member;

        System.runAs(admin){
            PdfWorkspaceInfo__c info = new PdfWorkspaceInfo__c(
                PdfWorkspaceId__c = workspace.Id
            );
            insert info;

            Account account = new Account(
                Name = ACCOUNT_NAME, 
                Phone = '605605605', 
                Website = 'http://www.test.org', 
                BillingStreet = 'Legnicka 48', 
                BillingCity = 'Wrocław', 
                BillingCountry = 'Poland');
            insert account;

            List<Contact> contacts = new List<Contact>();

            for (Integer i = 0; i < 5; i++){
                Contact contact = new Contact(
                    FirstName = 'Jan', 
                    LastName = 'Kowalski' + i, 
                    Phone = '6056055' + i, 
                    AccountId = account.Id);
                contacts.add(contact);
            }
            insert contacts;
        }
    }

    @IsTest
    static void testCreateContentVersionInRecordLibrary(){
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = :ACCOUNT_NAME
                           LIMIT 1];

        User admin = [SELECT Id
                      FROM User
                      WHERE Name = :ADMIN_LASTNAME];

        

        Id newDocumentId;
        System.runAs(admin){
            Test.startTest();
            newDocumentId = FileController.savePdfToContentVersion(account.Id, true);
            Test.stopTest();
        }

        List<ContentDocument> newDocuments = [SELECT Id
                                              FROM ContentDocument
                                              WHERE Id = :newDocumentId];
        System.assertEquals(1, newDocuments.size());
    }

    @IsTest
    static void testCreateContentVersionInPdfsLibrary(){
        Account account = [SELECT Id
                           FROM Account
                           WHERE Name = :ACCOUNT_NAME
                           LIMIT 1];

        User admin = [SELECT Id
                      FROM User
                      WHERE Name = :ADMIN_LASTNAME];

        Id newDocumentId;

        System.runAs(admin){
            Test.startTest();
            newDocumentId = FileController.savePdfToContentVersion(account.Id, false);
            Test.stopTest();
        }

        ContentWorkspace pdfsLibrary = [SELECT Id
                                        FROM ContentWorkspace
                                        WHERE Name = :LIBRARY_NAME];
        List<ContentDocumentLink> links = [SELECT ContentDocumentId
                                           FROM ContentDocumentLink
                                           WHERE LinkedEntityId = :pdfsLibrary.Id];
        System.assertEquals(newDocumentId, links[0].ContentDocumentId);
    }

}
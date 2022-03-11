public class SelectorService{
    public static ContentDocument selectContentDocumentByContentVersionId(Id contentVersionId){
        return [SELECT Id
                FROM ContentDocument
                WHERE LatestPublishedVersionId = :contentVersionId
                LIMIT 1];
    }

    public static List<ContentDocumentLink> selectDocumentLinksListByDocumentId(Id documentId){
        return [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
                FROM ContentDocumentLink
                WHERE ContentDocumentId = :documentId];
    }

    public static List<ContentDocumentLink> selectDocumentLinksByTitleAndEntity(String title, Id linkedEntityId){
        return [SELECT Id, ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :linkedEntityId AND ContentDocument.Title = :title
                LIMIT 1];
    }

    public static List<ContentDocumentLink> selectDocumentLinksByIds(List<Id> ids){
        return [SELECT Id
                FROM ContentDocumentLink
                WHERE Id IN:ids];
    }

    public static ContentWorkspace selectContentWorkspaceByName(String name){
        return [SELECT Id
                FROM ContentWorkspace
                WHERE Name = :name];
    }

    public static Account selectAccountById(Id accountId){
        return [SELECT Id, Name, Phone, Website, BillingStreet, BillingCountry, BillingCity
                FROM Account
                WHERE Id = :accountId];
    }

    public static List<Contact> selectContactsByAccountId(Id accountId){
        return [SELECT Id, Name, Phone
                FROM Contact
                WHERE AccountId = :accountId];
    }

}
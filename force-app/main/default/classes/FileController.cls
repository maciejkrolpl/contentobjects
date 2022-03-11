public class FileController{
    @AuraEnabled
    public static String savePdfToContentVersion(Id recordId, Boolean saveToRecord){
        String name = SelectorService.selectAccountById(recordId).Name;

        PdfWorkspaceInfo__c workspaceInfo = [SELECT PdfWorkspaceId__c FROM PdfWorkspaceInfo__c];
        Id libraryId = workspaceInfo.PdfWorkspaceId__c;

        PageReference page = Page.accountDetailsPdf;
        page.getParameters().put('id', recordId);
        ContentVersion cv = new ContentVersion();
        cv.Title = name;
        cv.PathOnClient = name + '.pdf';
        Id entityId = (saveToRecord==TRUE) ? recordId : libraryId;

        // Methods defined as TestMethod do not support getContent call
        if (Test.isRunningTest()){                            
            cv.VersionData = blob.valueOf('Unit.Test');
        } else{
            cv.VersionData = page.getContentAsPDF();
        }

        Id existingContentDocumentId = getContentDocumentId(entityId, name);
        Id newContentDocumentId;

        if (existingContentDocumentId != null){
            cv.ContentDocumentId = existingContentDocumentId;
            newContentDocumentId = existingContentDocumentId;
            insert cv;
        } else{
            insert cv;
            ContentDocument document = SelectorService.selectContentDocumentByContentVersionId(cv.Id);
            assignContentDocumentToEntity(document.Id, entityId);
            newContentDocumentId = document.Id;
        }


        return (String) newContentDocumentId;
    }

    private static Id getContentDocumentId(Id libraryId, String name){
        List<ContentDocumentLink> cdls = SelectorService.selectDocumentLinksByTitleAndEntity(name, libraryId);

        if (cdls.isEmpty()){
            return null;
        }
        return cdls[0].ContentDocumentId;
    }

    private static Boolean assignContentDocumentToEntity(Id documentId, Id entityId){
        Boolean result = true;
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        List<Id> oldLinksIds = new List<Id>();

        for (ContentDocumentLink oldLink : SelectorService.selectDocumentLinksListByDocumentId(documentId)){
            ContentDocumentLink clonedLink = oldLink.clone();
            clonedLink.LinkedEntityId = entityId;
            clonedLink.ShareType = oldLink.ShareType;
            newLinks.add(clonedLink);
            oldLinksIds.add(oldLink.Id);
        }

        try{
            insert newLinks;
        } catch (Exception e){
            System.debug('error inserting new ContentDocumentLinks ' + e.getMessage());
            result = false;
        }

        List<ContentDocumentLink> oldLinks = SelectorService.selectDocumentLinksByIds(oldLinksIds);

        try{
            delete oldLinks;
        } catch (Exception e){
            System.debug('error deleting old ContentDocumentLinks ' + e.getMessage());
            result = false;
        }

        return result;
    }

}
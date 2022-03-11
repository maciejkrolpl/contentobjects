public class AccountDetailsPdfController{
    private Id recordId;
    private Account account;
    private List<Contact> contacts;

    public AccountDetailsPdfController(){
        this.recordId = ApexPages.currentPage().getParameters().get('id');
        this.account = SelectorService.selectAccountById(this.recordId);
        this.contacts = SelectorService.selectContactsByAccountId(this.recordId);
        String fileName = account.Name + '.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
    }

    public Account getAccount(){
        return this.account;
    }

    public List<Contact> getContacts(){
        return this.contacts;
    }

}
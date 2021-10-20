global class CLN_CommunityLicenseUpdateBatch implements Database.Batchable<sObject>,Database.Stateful {
    

    global Static String clnCommunityProfilName = 'CLN COMMUNITY MEMBER';
    public integer batchsizelimit;
    
    public CLN_CommunityLicenseUpdateBatch(integer batchsizelimit){
      this.batchsizelimit = batchsizelimit;
    }
    
    global database.QueryLocator start(database.BatchableContext bc){
        string query='SELECT Id,firstname,lastname,profile.name FROM User Where profile.name =:clnCommunityProfilName and isactive = true limit '+batchsizelimit;
        return Database.getQueryLocator(query);
    }
    
    global void execute(database.BatchableContext bc, List<User>users){
        List<User> UpdateUsers = new List<User>();
        for(Integer i=0; i<users.size(); i++) {
            User userIns = new user();
            userIns.id =   users.get(i).Id;
            userIns.ProfileId = Label.clnCommunityLoginProfilleId;  
            UpdateUsers.add(userIns);
        }
        
        try{
            Database.SaveResult[] res = Database.update(UpdateUsers,false);
        }
        catch(exception e){
            system.debug('failure records'+e.getMessage());
        }
    }
    
    global void finish(database.BatchableContext bc){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email
                                                  from AsyncApexJob where Id =:bc.getJobId()];
        
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String emailAddress =  System.Label.CommunityLicenseNotfyEmail;
            String[] toAddresses = emailAddress.split(';');
           // String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Community License Update Batch Job ' + a.Status);
            mail.setPlainTextBody('Total Number of records processed ' + a.TotalJobItems +
           ' with '+ a.NumberOfErrors + ' failures.');
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}
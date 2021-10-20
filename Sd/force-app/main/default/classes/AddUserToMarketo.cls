public class AddUserToMarketo {
    private static String clientID;
    private static String clientSecret;
    
    @future (Callout=true)
    public static void addUser(Id userId, String action) {
        setConstants();
        
        User u = [SELECT Id, Country, Email, FirstName, LastName FROM User WHERE Id = :userId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        String url = Label.Marketo_API_URL;
        
        request.setEndpoint(url + '/identity/oauth/token?grant_type=client_credentials&client_id=' + clientID + '&client_secret=' + clientSecret);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        String token = '';
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> serverResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            token = (String) serverResults.get('access_token');
            System.debug('Authentication Successful');
        }
        
        String body = '{"action":"createOrUpdate","lookupField":"email","input":[';
        String email = u.Email;
        String firstName = u.FirstName;
        String lastName = u.LastName;
        String country = u.Country;
        
        //body += '{"Email":"' + email + '","FirstName":"' + firstName + '","LastName":"' + lastName + '","Country":"' + country + '","CLN_FLAG":true ,"cLNCampaignID":"welcome"}';
        if (action == 'add')
        	body += '{"Email":"' + email + '","FirstName":"' + firstName + '","LastName":"' + lastName + '","Country":"' + country + '","CLN_FLAG":true ,"cLNAPICampaignID":"welcome"}';
        else if (action == 'update')
            body += '{"Email":"' + email + '","FirstName":"' + firstName + '","LastName":"' + lastName + '","Country":"' + country + '","CLN_FLAG":true}';
        body += ']}';
        
        request = new HttpRequest();
        request.setEndpoint(url + '/rest/v1/leads.json');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + token);
        request.setBody(body);
        response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> serverResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Create Object Success');
        }
    }
    
    private static void setConstants() {
        Map<String, String> marketoConstants = MarketoAuthorization.getAuthorization();
        
        //clientID = '2cb6997e-93c5-40ac-8fd1-ca48717def07';
        clientID = marketoConstants.get('clientID');
        //clientSecret = 'GyedNUjKuAUqS5iAs9iDAwqYY2Yhkxbg';
        clientSecret = marketoConstants.get('clientSecret');
    }
}
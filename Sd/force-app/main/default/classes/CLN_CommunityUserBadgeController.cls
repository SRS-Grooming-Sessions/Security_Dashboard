/* 
*Created by Baskar on  Nov 21 2019 
*Based on User ,  Displaying the Certificate . if the User Id is Current User Id show all active certificates.
* if User Id is Not Current User Id, Checks whether the user field Display my Ceritificate is True . if
* yes , other user Certificates also can see
*/
public class CLN_CommunityUserBadgeController 
{
    @AuraEnabled
    public static List<CLN_Cert__c> userCertificationMethod(String userId)
    {
        Id usrId;
        System.debug('userId'+userId);
        ID  Curretn_User_Id = UserInfo.getUserId();
        List<CLN_Cert__c> urlList = new List<CLN_Cert__c>();
        List<String> certName = new List<String>();
        Map<String,CLN_Cert__c> mapCer =  new Map<String,CLN_Cert__c>();
        if(userId != null && userId!=Curretn_User_Id) {
            for(User usr : [Select id ,Display_My_Certs_in_CLN__c from User where id=:userId]){
                if(usr.Display_My_Certs_in_CLN__c == true){
                    usrId =  usr.id;
                }
            }
        }
        else if(userId == Curretn_User_Id && userId != null){
            usrId = userId;
        }
        System.debug('usrId'+usrId);
        if(usrId != null) {
            System.debug('usrId--'+usrId);
            for(CLN_Cert__c cln  : [Select id,expirationDate__c,certName__c,Certificate_URL__c,userId__c from CLN_Cert__c where userId__c=:usrId AND State__c='accepted' AND show_badge_public__c = true AND Certificate_URL__c != null]) {
                System.debug('cln--'+cln);
                if(cln.expirationDate__c==null || (cln.expirationDate__c!=null && cln.expirationDate__c>Date.Today())){  

                    mapCer.put(cln.certName__c,cln);
                    
                }     
            }            
        }
        if(!mapCer.keySet().isEmpty()){
            System.debug('Before removing urlList'+mapCer);
            List<Cisco_Cert__c> listCerts = [select Id,Name__c from Cisco_Cert__c  WHERE Name__c IN:mapCer.keySet() AND Hide_Certificate__c = true];
            System.debug('**listCerts**'+listCerts);
            for(Cisco_Cert__c Cert: listCerts){
                certName.add(Cert.Name__c);
            }
            for (Integer i = (certName.size()-1) ; i>= 0 ; i--){
                System.debug('**InsideCerts**'+mapCer.get(certName.get(i)));
                if(mapCer.get(certName.get(i)) != null){
                   mapCer.remove(certName.get(i));
                }
            }
            System.debug('After removing urlList'+mapCer);
            return mapCer.values();
        }
 
        System.debug('null');
        return null;
    }
}
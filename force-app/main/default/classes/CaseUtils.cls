public class CaseUtils {
    public Map<String,String> getAllChildAttachments(List<Case> cases){
        List<Id> liChildDocumentIds = new List<Id>();
        Map<String,String> results = new Map<String,String>();    
        for(ContentDocumentLink cdl :  [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in (Select id from EmailMessage  where parentid =: cases)]){
            liChildDocumentIds.add(cdl.ContentDocumentId);
        }
        for(ContentVersion bodytext : [SELECT Id, Title, ContentSize, Description, FileExtension,
                                       FileType, IsLatest, VersionData FROM ContentVersion WHERE ContentDocumentId IN: liChildDocumentIds]){
                                           for(Case c : cases){
                                                //String s = '';

                                               if('Fwd: I: POSTA CERTIFICATA: ' +bodytext.Title == c.Subject){
                                                   Blob b = bodytext.VersionData;
                                                   //S//tring s = b.toString();
                                                   ////s = bodytext.VersionData.tostring();
                                                   
                                                   if(b.size() < 5000000){
                                                      String s = EncodingUtil.base64Decode(EncodingUtil.base64Encode(b)).toString();
                                                      results.put(c.id,s);
                                                   }
                                                   
                                                   //System.debug('*********:' + s);
                                                  //results.put(c.id,s);                                  
                                               }                                      
                                           }
                                       }
        return results;
    }
/*public List<Id> getAllChildCases(List<Case> cases){
        //List<Case> allCases = [Select Id, Subject from Case where origin ='PEC' or origin ='Posta elettronica' ];
         String regex = '\\s*\\bCONSEGNA\\b\\s*[^a-zA-Z0-9]\\s';
        String regex1 = '\\s*\\bACCETTAZIONE\\b\\s*[^a-zA-Z0-9]\\s';
        String regex2 = '\\s*\\bRICEVUTA PROTOCOLLO\\b\\s*[^a-zA-Z0-9]\\s';
        String regex3 = '\\s*\\bPOSTA CERTIFICATA\\b\\s*[^a-zA-Z0-9]\\s';
    List<String> allSubjects = new List<String>();
    List<Case> toupdatecase = new List<Case>();
    for(Case cs : cases) {
        allSubjects.add(cs.Subject);        
    }
    
    List<Case> allSubjectCases = [Select Id, Subject from Case where Origin = 'PEC' AND parentid = null AND Createddate = LAST_N_DAYS:30 ];
		
        List<Id> result = new List<Id>();
        
        for(Case c : cases){
            for(Case b : allSubjectCases){
               /*
                if((c.Subject.toUppercase().replaceAll(regex, '')==b.Subject.replaceAll(regex3, ''))||
                   (c.Subject.toUppercase().replaceAll(regex1, '')==b.Subject.replaceAll(regex3, ''))||
                   (c.Subject.toUppercase().replaceAll(regex2, '')==b.Subject.replaceAll(regex3, ''))){ 
                     
                       if(b.id != c.id){
                           c.ParentId = b.id;
                              result.add(c.Id);
                          }     
                }*/
                //
                    /*    if(b.id != c.id && b.Subject == c.Subject){
                              c.ParentId = b.id;
                              c.status = 'Inoltrato';
                              result.add(c.Id);
                              toupdatecase.add(c);
                              break;
                          } 
            }    
        }
    	//update toupdatecase;
     return result;   
    } */
public List<Case> getAllChildCasesObj(List<Case> cases){
        //List<Case> allCases = [Select Id, Subject from Case where origin ='PEC' or origin ='Posta elettronica' ];
         String regex = '\\s*\\bCONSEGNA\\b\\s*[^a-zA-Z0-9]\\s';
        String regex1 = '\\s*\\bACCETTAZIONE\\b\\s*[^a-zA-Z0-9]\\s';
        String regex2 = '\\s*\\bRICEVUTA PROTOCOLLO\\b\\s*[^a-zA-Z0-9]\\s';
        String regex3 = '\\s*\\bPOSTA CERTIFICATA\\b\\s*[^a-zA-Z0-9]\\s';
    List<String> allSubjects = new List<String>();
    List<Case> toupdatecase = new List<Case>();
    for(Case cs : cases) {
        allSubjects.add(cs.Subject);        
    }
    
    List<Case> allSubjectCases = [Select Id, Subject from Case where parentid = null AND Createddate = LAST_N_DAYS:15 ];
	
    	System.debug('*******1:' + allSubjectCases);
    	System.debug('*******2:' + cases);
    
        List<Id> result = new List<Id>();
        for(Case c : cases){
            for(Case b : allSubjectCases){
                
                        if(b.id != c.id && b.Subject.contains(c.Subject)){
                              c.ParentId = b.id;
                              //c.status = 'Inoltrato';
                              result.add(c.Id);
                              toupdatecase.add(c);
                              break;
                          } 
            }    
        }
    	//update toupdatecase;
     return toupdatecase;   
    }
}
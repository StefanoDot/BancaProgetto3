@IsTest
public class BP_digitalAssignmentWrapper_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"opportunityId\":\"sadada\",'+
		'  \"quoteId\":\"\",'+
		'  \"processGuid\":\"\",'+
		'  \"expirationTime\":\"\",'+
		'  \"refPartnerEmail\":\"\",'+
		'  \"refSalesEmail\":\"\",'+
		'  \"salesSupportEmail\":\"\",'+
		'  \"users\":['+
		'   {'+
		'     \"type\":\"\",'+
		'     \"sendEmail\":\"\",'+
		'     \"name\":\"\",'+
		'     \"surname\":\"\",'+
		'     \"email\":\"\",'+
		'     \"phoneNumber\":\"\",'+
		'     \"taxCode\":\"\",'+
		'     \"idSalesforce\":\"\",'+
		'     \"contactId\":\"\",'+
		'     \"gender\":\"\",'+
		'     \"dateOfBirth\":\"\",'+
		'     \"cityOfBirth\":\"\",'+
		'     \"provinceOfBirth\":\"\",'+
		'     \"stateOfBirth\":\"\",'+
		'     \"address\":\"\",'+
		'     \"city\":\"\",'+
		'     \"province\":\"\",'+
		'     \"state\":\"\",'+
		'     \"docs\":{'+
		'        \"identityDoc\":{'+
		'         \"docType\":\"\",'+
		'         \"idNumber\":\"\",'+
		'         \"idReleaseDate\":\"\",'+
		'         \"idExpiryDate\":\"\",'+
		'         \"idEmittingAuthority\":\"\",'+
		'         \"pluginDocumentId\":\"\"'+
		'        },'+
		'        \"pluginCfId\":\"fafdfsdfsdf\"'+
		'     }'+
		'   }'+
		'  ]'+
		'}';
		BP_digitalAssignmentWrapper obj = BP_digitalAssignmentWrapper.parse(json);
		System.assert(obj != null);
	}
}
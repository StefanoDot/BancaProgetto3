public class BP_digitalAssignmentWrapper {

	public class DocId {
		public String docType;
		public String idNumber;
		public String idReleaseDate;
		public String idExpiryDate;
		public String idEmittingAuthority;
		public String pluginDocumentId;
	}

	public class Docs {
		public DocId identityDoc;
		public String pluginCfId;
	}

	public class Users {
		public String type;
		public String sendMail;
		public String name;
		public String surname;
		public String email;
		public String phoneNumber;
		public String taxCode;
		public String idSalesforce;
		public String contactId;
		public String gender;
		public String dateOfBirth;
		public String cityOfBirth;
		public String provinceOfBirth;
		public String stateOfBirth;
		public String address;
		public String city;
		public String province;
		public String state;
		public Docs docs;
	}

	public String opportunityId;
	public String quoteId;
	public String processGuid;
	public String expirationTime;
	public String refPartnerEmail;
	public String refSalesEmail;
	public String salesSupportEmail;
	public List<Users> users;

	
	public static BP_digitalAssignmentWrapper parse(String json) {
		return (BP_digitalAssignmentWrapper) System.JSON.deserialize(json, BP_digitalAssignmentWrapper.class);
	}
}
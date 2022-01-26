global with sharing virtual class ApexServiceLibraryCnt {

    public static Map<String, String> asMap(String jsonInput) {
        if (jsonInput == 'null' || String.isBlank(jsonInput)) {
            return new Map<String, String>();
        }
        return (Map<String, String>) JSON.deserialize(jsonInput, Map<String, String>.class);
    }

}
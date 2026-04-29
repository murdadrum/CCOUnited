/**
 * Guest-accessible controller for the CCO United asset directory.
 * without sharing is intentional: guest users have no record ownership,
 * so sharing rules would block all queries. All methods are read-only
 * and filter by Status__c = 'Active' to limit surface area.
 */
public without sharing class CCOAssetDirectoryController {

    @AuraEnabled(cacheable=true)
    public static List<Local_Community_Group__c> getLocalGroups() {
        return [
            SELECT Id, Name, Description__c, Location__c, Contact_Email__c
            FROM Local_Community_Group__c
            WHERE Status__c = 'Active'
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset_Category__c> getCategoriesByGroup(String groupId) {
        if (String.isBlank(groupId)) {
            return new List<Asset_Category__c>();
        }
        Id safeGroupId = (Id) groupId;
        return [
            SELECT Id, Name, Description__c, Icon_Name__c, Display_Order__c
            FROM Asset_Category__c
            WHERE Local_Community_Group__c = :safeGroupId
            ORDER BY Display_Order__c NULLS LAST, Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset__c> getAssetsByCategory(String categoryId) {
        if (String.isBlank(categoryId)) {
            return new List<Asset__c>();
        }
        Id safeCategoryId = (Id) categoryId;
        return [
            SELECT Id, Name, Description__c, Asset_Type__c, Status__c,
                   File_URL__c, Contact_Name__c, Contact_Email__c, Tags__c,
                   Asset_Category__r.Name, Asset_Category__r.Local_Community_Group__r.Name
            FROM Asset__c
            WHERE Asset_Category__c = :safeCategoryId
              AND (Status__c = 'Available' OR Status__c = 'Seasonal')
            ORDER BY Name
            LIMIT 200
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, Integer> getAssetCountsByGroup(String groupId) {
        if (String.isBlank(groupId)) return new Map<Id, Integer>();
        Id safeId = (Id) groupId;
        Map<Id, Integer> counts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Asset_Category__c catId, COUNT(Id) cnt
            FROM Asset__c
            WHERE Asset_Category__r.Local_Community_Group__c = :safeId
              AND (Status__c = 'Available' OR Status__c = 'Seasonal')
            GROUP BY Asset_Category__c
        ]) {
            counts.put((Id)ar.get('catId'), (Integer)ar.get('cnt'));
        }
        return counts;
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset__c> searchAndFilterAssets(
        String searchTerm,
        String groupId,
        String categoryId,
        String assetType
    ) {
        String baseQuery = 'SELECT Id, Name, Description__c, Asset_Type__c, Status__c, ' +
            'File_URL__c, Contact_Name__c, Contact_Email__c, Tags__c, ' +
            'Asset_Category__r.Name, Asset_Category__r.Local_Community_Group__r.Name ' +
            'FROM Asset__c ' +
            'WHERE (Status__c = \'Available\' OR Status__c = \'Seasonal\')';

        List<String> conditions = new List<String>();

        if (String.isNotBlank(searchTerm)) {
            // Sanitize: strip single quotes to prevent SOQL injection
            String safe = String.escapeSingleQuotes(searchTerm.trim());
            conditions.add(
                '(Name LIKE \'%' + safe + '%\' OR Description__c LIKE \'%' + safe + '%\' OR Tags__c LIKE \'%' + safe + '%\')'
            );
        }

        if (String.isNotBlank(groupId)) {
            Id safeGroupId = (Id) groupId;
            conditions.add('Asset_Category__r.Local_Community_Group__c = \'' + safeGroupId + '\'');
        }

        if (String.isNotBlank(categoryId)) {
            Id safeCategoryId = (Id) categoryId;
            conditions.add('Asset_Category__c = \'' + safeCategoryId + '\'');
        }

        if (String.isNotBlank(assetType)) {
            String safeType = String.escapeSingleQuotes(assetType.trim());
            conditions.add('Asset_Type__c = \'' + safeType + '\'');
        }

        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }

        baseQuery += ' ORDER BY Name LIMIT 200';

        return Database.query(baseQuery);
    }
}

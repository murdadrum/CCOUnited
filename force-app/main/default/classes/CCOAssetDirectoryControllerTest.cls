@isTest(SeeAllData=false)
private class CCOAssetDirectoryControllerTest {

    @TestSetup
    static void makeData() {
        National_Organization__c org = new National_Organization__c(
            Name = 'CCO',
            Status__c = 'Active'
        );
        insert org;

        List<Local_Community_Group__c> groups = new List<Local_Community_Group__c>{
            new Local_Community_Group__c(
                Name = 'Keys CCO',
                National_Organization__c = org.Id,
                Location__c = 'Florida Keys, FL',
                Status__c = 'Active'
            ),
            new Local_Community_Group__c(
                Name = 'Kansas CCO',
                National_Organization__c = org.Id,
                Location__c = 'Kansas',
                Status__c = 'Active'
            ),
            new Local_Community_Group__c(
                Name = 'Inactive Group',
                National_Organization__c = org.Id,
                Status__c = 'Inactive'
            )
        };
        insert groups;

        Local_Community_Group__c keysGroup = groups[0];
        Local_Community_Group__c kansasGroup = groups[1];

        List<Asset_Category__c> categories = new List<Asset_Category__c>();
        for (Integer i = 1; i <= 3; i++) {
            categories.add(new Asset_Category__c(
                Name = 'Keys Category ' + i,
                Local_Community_Group__c = keysGroup.Id,
                Display_Order__c = i
            ));
            categories.add(new Asset_Category__c(
                Name = 'Kansas Category ' + i,
                Local_Community_Group__c = kansasGroup.Id,
                Display_Order__c = i
            ));
        }
        insert categories;

        List<Asset__c> assets = new List<Asset__c>();
        for (Asset_Category__c cat : categories) {
            for (Integer i = 1; i <= 5; i++) {
                assets.add(new Asset__c(
                    Name = cat.Name + ' Asset ' + i,
                    Asset_Category__c = cat.Id,
                    Asset_Type__c = (Math.mod(i, 2) == 0) ? 'Skill' : 'Physical',
                    Status__c = 'Available',
                    Description__c = 'Description for ' + cat.Name + ' Asset ' + i,
                    Tags__c = 'tag' + i + ',community'
                ));
            }
        }
        // Add one unavailable asset to verify it is excluded
        assets.add(new Asset__c(
            Name = 'Unavailable Asset',
            Asset_Category__c = categories[0].Id,
            Asset_Type__c = 'Physical',
            Status__c = 'Unavailable'
        ));
        insert assets;
    }

    @isTest
    static void testGetLocalGroups_returnsActiveOnly() {
        Test.startTest();
        List<Local_Community_Group__c> result = CCOAssetDirectoryController.getLocalGroups();
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Expected 2 active groups; inactive group should be excluded');
        Set<String> names = new Set<String>();
        for (Local_Community_Group__c g : result) {
            names.add(g.Name);
        }
        System.assert(names.contains('Keys CCO'), 'Keys CCO should be in results');
        System.assert(names.contains('Kansas CCO'), 'Kansas CCO should be in results');
        System.assert(!names.contains('Inactive Group'), 'Inactive Group must be excluded');
    }

    @isTest
    static void testGetCategoriesByGroup_correctGroupFiltered() {
        Local_Community_Group__c keysGroup = [
            SELECT Id FROM Local_Community_Group__c WHERE Name = 'Keys CCO' LIMIT 1
        ];

        Test.startTest();
        List<Asset_Category__c> result = CCOAssetDirectoryController.getCategoriesByGroup(keysGroup.Id);
        Test.stopTest();

        System.assertEquals(3, result.size(), 'Expected 3 categories for Keys CCO');
        for (Asset_Category__c cat : result) {
            System.assert(cat.Name.startsWith('Keys Category'), 'Only Keys categories should be returned');
        }
    }

    @isTest
    static void testGetCategoriesByGroup_blankIdReturnsEmpty() {
        Test.startTest();
        List<Asset_Category__c> result = CCOAssetDirectoryController.getCategoriesByGroup('');
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Blank groupId should return empty list');
    }

    @isTest
    static void testGetAssetsByCategory_correctCategoryFiltered() {
        Asset_Category__c cat = [
            SELECT Id FROM Asset_Category__c WHERE Name = 'Keys Category 1' LIMIT 1
        ];

        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.getAssetsByCategory(cat.Id);
        Test.stopTest();

        // 5 available assets; 1 unavailable asset should be excluded
        System.assertEquals(5, result.size(), 'Expected 5 available assets; unavailable should be excluded');
        for (Asset__c a : result) {
            System.assertNotEquals('Unavailable', a.Status__c, 'Unavailable assets must be excluded');
        }
    }

    @isTest
    static void testGetAssetsByCategory_blankIdReturnsEmpty() {
        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.getAssetsByCategory('');
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Blank categoryId should return empty list');
    }

    @isTest
    static void testSearchAndFilterAssets_byTerm() {
        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets('Keys Category 1', null, null, null);
        Test.stopTest();

        System.assert(result.size() > 0, 'Search by term should return results');
        for (Asset__c a : result) {
            System.assert(
                a.Name.contains('Keys Category 1') || (a.Description__c != null && a.Description__c.contains('Keys Category 1')),
                'Results must match search term in Name or Description'
            );
        }
    }

    @isTest
    static void testSearchAndFilterAssets_byType() {
        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets(null, null, null, 'Skill');
        Test.stopTest();

        System.assert(result.size() > 0, 'Filter by type should return results');
        for (Asset__c a : result) {
            System.assertEquals('Skill', a.Asset_Type__c, 'All returned assets must be of type Skill');
        }
    }

    @isTest
    static void testSearchAndFilterAssets_byGroup() {
        Local_Community_Group__c keysGroup = [
            SELECT Id FROM Local_Community_Group__c WHERE Name = 'Keys CCO' LIMIT 1
        ];

        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets(null, keysGroup.Id, null, null);
        Test.stopTest();

        System.assert(result.size() > 0, 'Filter by group should return results');
        for (Asset__c a : result) {
            System.assertEquals(
                'Keys CCO',
                a.Asset_Category__r.Local_Community_Group__r.Name,
                'All results must belong to Keys CCO'
            );
        }
    }

    @isTest
    static void testSearchAndFilterAssets_combined() {
        Local_Community_Group__c keysGroup = [
            SELECT Id FROM Local_Community_Group__c WHERE Name = 'Keys CCO' LIMIT 1
        ];

        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets('Asset', keysGroup.Id, null, 'Physical');
        Test.stopTest();

        for (Asset__c a : result) {
            System.assertEquals('Physical', a.Asset_Type__c, 'Combined filter: type must be Physical');
            System.assertEquals('Keys CCO', a.Asset_Category__r.Local_Community_Group__r.Name, 'Combined filter: group must be Keys CCO');
        }
    }

    @isTest
    static void testSearchAndFilterAssets_noResultsForBadTerm() {
        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets('ZZZNOMATCH_XYZ123', null, null, null);
        Test.stopTest();
        System.assertEquals(0, result.size(), 'No results expected for unmatched search term');
    }

    @isTest
    static void testBulkLoad_200Assets() {
        Asset_Category__c cat = [SELECT Id FROM Asset_Category__c LIMIT 1];

        List<Asset__c> largeList = new List<Asset__c>();
        for (Integer i = 0; i < 210; i++) {
            largeList.add(new Asset__c(
                Name = 'Bulk Asset ' + i,
                Asset_Category__c = cat.Id,
                Asset_Type__c = 'Physical',
                Status__c = 'Available'
            ));
        }
        insert largeList;

        Test.startTest();
        List<Asset__c> result = CCOAssetDirectoryController.getAssetsByCategory(cat.Id);
        Test.stopTest();

        System.assertEquals(200, result.size(), 'LIMIT 200 must be respected on bulk queries');
    }

    @isTest
    static void testGetAssetCountsByGroup_returnsCorrectCounts() {
        Local_Community_Group__c keysGroup = [
            SELECT Id FROM Local_Community_Group__c WHERE Name = 'Keys CCO' LIMIT 1
        ];

        Test.startTest();
        Map<Id, Integer> counts = CCOAssetDirectoryController.getAssetCountsByGroup(keysGroup.Id);
        Test.stopTest();

        System.assertNotEquals(0, counts.size(), 'Expected counts for Keys CCO categories');
        for (Integer cnt : counts.values()) {
            System.assert(cnt > 0, 'Each category count should be > 0');
        }
    }

    @isTest
    static void testGetAssetCountsByGroup_blankIdReturnsEmpty() {
        Test.startTest();
        Map<Id, Integer> counts = CCOAssetDirectoryController.getAssetCountsByGroup('');
        Test.stopTest();
        System.assertEquals(0, counts.size(), 'Blank groupId should return empty map');
    }

    @isTest
    static void testSearchInjectionSafety() {
        Test.startTest();
        // Single quote injection attempt — should not throw SOQL exception
        List<Asset__c> result = CCOAssetDirectoryController.searchAndFilterAssets('test\' OR 1=1 --', null, null, null);
        Test.stopTest();
        // No assertion on count — just validating no exception is thrown
        System.assert(result != null, 'Result should not be null after injection attempt');
    }
}

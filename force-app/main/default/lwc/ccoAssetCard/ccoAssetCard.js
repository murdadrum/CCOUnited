import { LightningElement, api } from 'lwc';

const TYPE_BADGE_MAP = {
    Physical: 'physical',
    Skill: 'skill',
    Credential: 'credential',
    Interest: 'interest',
    Person: 'person',
    Partner: 'partner'
};

export default class CcoAssetCard extends LightningElement {
    @api asset = {};

    get shortDescription() {
        const desc = this.asset.Description__c || '';
        return desc.length > 150 ? desc.substring(0, 147) + '...' : desc;
    }

    get typeBadgeClass() {
        return TYPE_BADGE_MAP[this.asset.Asset_Type__c] || 'default';
    }

    get statusClass() {
        const s = this.asset.Status__c;
        if (s === 'Available') return 'available';
        if (s === 'Seasonal') return 'seasonal';
        return 'unavailable';
    }

    get mailtoLink() {
        return this.asset.Contact_Email__c ? 'mailto:' + this.asset.Contact_Email__c : null;
    }

    get tagList() {
        return (this.asset.Tags__c || '').split(',')
            .map(t => t.trim()).filter(Boolean)
            .map((t, i) => ({ key: i, label: t }));
    }

    get hasTags() {
        return this.tagList.length > 0;
    }
}

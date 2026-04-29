import { LightningElement, api } from 'lwc';

const DEFAULT_ICON = 'standard:asset_object';

export default class CcoCategoryCard extends LightningElement {
    @api category = {};
    @api assetCount = 0;

    get iconName() {
        return this.category.Icon_Name__c || DEFAULT_ICON;
    }

    get shortDescription() {
        const desc = this.category.Description__c || '';
        return desc.length > 100 ? desc.substring(0, 97) + '...' : desc;
    }

    handleClick() {
        this._fire();
    }

    handleKeyPress(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            this._fire();
        }
    }

    _fire() {
        this.dispatchEvent(new CustomEvent('categoryselect', {
            detail: { id: this.category.Id, name: this.category.Name }
        }));
    }
}

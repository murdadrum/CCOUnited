import { LightningElement, api } from 'lwc';

export default class CcoLocalGroupCard extends LightningElement {
    @api group = {};
    @api groupIndex = 0;

    get bandClass() {
        return 'cco-card__band cco-card__band--' + (this.groupIndex % 7);
    }

    get shortDescription() {
        const desc = this.group.Description__c || '';
        return desc.length > 120 ? desc.substring(0, 117) + '...' : desc;
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
        this.dispatchEvent(new CustomEvent('groupselect', {
            detail: { id: this.group.Id, name: this.group.Name }
        }));
    }
}

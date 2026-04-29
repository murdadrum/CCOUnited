import { LightningElement, api, wire, track } from 'lwc';
import getLocalGroups from '@salesforce/apex/CCOAssetDirectoryController.getLocalGroups';

const ASSET_TYPES = ['Physical', 'Skill', 'Credential', 'Interest', 'Person', 'Partner'];

export default class CcoFilterPanel extends LightningElement {
    @api selectedGroupId = '';
    @api selectedCategoryId = '';
    @api selectedAssetType = '';

    @wire(getLocalGroups)
    _groups;

    get groupOptions() {
        const opts = [{ label: 'All Groups', value: '' }];
        if (this._groups.data) {
            this._groups.data.forEach(g => opts.push({ label: g.Name, value: g.Id }));
        }
        return opts;
    }

    get typeOptions() {
        return [
            { label: 'All Types', value: '' },
            ...ASSET_TYPES.map(t => ({ label: t, value: t }))
        ];
    }

    get hasFilters() {
        return (this.selectedGroupId || this.selectedAssetType);
    }

    handleGroupChange(event) {
        this._fireChange({ groupId: event.detail.value, assetType: this.selectedAssetType });
    }

    handleTypeChange(event) {
        this._fireChange({ groupId: this.selectedGroupId, assetType: event.detail.value });
    }

    handleClear() {
        this._fireChange({ groupId: '', assetType: '' });
    }

    _fireChange(detail) {
        this.dispatchEvent(new CustomEvent('filterchange', { detail }));
    }
}

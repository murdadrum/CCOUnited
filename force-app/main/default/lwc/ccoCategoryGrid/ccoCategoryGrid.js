import { LightningElement, api, wire } from 'lwc';
import getCategoriesByGroup from '@salesforce/apex/CCOAssetDirectoryController.getCategoriesByGroup';
import getAssetCountsByGroup from '@salesforce/apex/CCOAssetDirectoryController.getAssetCountsByGroup';

export default class CcoCategoryGrid extends LightningElement {
    @api groupId;
    @api groupName;

    @wire(getCategoriesByGroup, { groupId: '$groupId' })
    _result;

    @wire(getAssetCountsByGroup, { groupId: '$groupId' })
    _counts;

    get isLoading() { return !this._result.data && !this._result.error; }
    get hasError() { return !!this._result.error; }
    get hasCategories() { return (this._result.data || []).length > 0; }

    get categoriesWithCounts() {
        const counts = this._counts.data || {};
        return (this._result.data || []).map(cat => ({
            ...cat,
            assetCount: counts[cat.Id] || 0
        }));
    }

    handleCategorySelect(event) {
        this.dispatchEvent(new CustomEvent('categoryselect', { detail: event.detail }));
    }
}

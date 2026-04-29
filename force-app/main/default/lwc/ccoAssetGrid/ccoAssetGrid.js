import { LightningElement, api, wire } from 'lwc';
import getAssetsByCategory from '@salesforce/apex/CCOAssetDirectoryController.getAssetsByCategory';
import searchAndFilterAssets from '@salesforce/apex/CCOAssetDirectoryController.searchAndFilterAssets';

export default class CcoAssetGrid extends LightningElement {
    @api categoryId;
    @api searchTerm;
    @api groupId;
    @api assetType;

    _searchResult = {};
    _categoryResult = {};

    @wire(getAssetsByCategory, { categoryId: '$categoryId' })
    wiredCategory(result) {
        if (this._isSearchMode) return;
        this._categoryResult = result;
    }

    @wire(searchAndFilterAssets, {
        searchTerm: '$searchTerm',
        groupId: '$groupId',
        categoryId: '$categoryId',
        assetType: '$assetType'
    })
    wiredSearch(result) {
        if (!this._isSearchMode) return;
        this._searchResult = result;
    }

    get _isSearchMode() {
        return !!(this.searchTerm || this.groupId || this.assetType);
    }

    get _activeResult() {
        return this._isSearchMode ? this._searchResult : this._categoryResult;
    }

    get isLoading() {
        const r = this._activeResult;
        return !r.data && !r.error;
    }

    get hasError() { return !!this._activeResult.error; }
    get assets() { return this._activeResult.data || []; }
    get hasAssets() { return this.assets.length > 0; }
    get resultCount() { return this.assets.length; }
}

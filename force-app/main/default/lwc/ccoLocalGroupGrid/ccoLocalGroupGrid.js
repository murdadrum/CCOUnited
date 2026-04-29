import { LightningElement, wire } from 'lwc';
import getLocalGroups from '@salesforce/apex/CCOAssetDirectoryController.getLocalGroups';

export default class CcoLocalGroupGrid extends LightningElement {
    @wire(getLocalGroups)
    _result;

    get isLoading() { return !this._result.data && !this._result.error; }
    get hasError() { return !!this._result.error; }
    get groups() { return this._result.data || []; }
    get hasGroups() { return this.groups.length > 0; }
    get groupsWithIndex() {
        return this.groups.map((group, idx) => ({ group, idx }));
    }

    handleGroupSelect(event) {
        this.dispatchEvent(new CustomEvent('groupselect', { detail: event.detail }));
    }
}

import { LightningElement, api } from 'lwc';

export default class CcoBreadcrumb extends LightningElement {
    @api
    get crumbs() {
        return this._crumbs || [];
    }

    set crumbs(value) {
        this._crumbs = (value || []).map((c, idx, arr) => ({
            ...c,
            isLast: idx === arr.length - 1
        }));
    }

    handleClick(event) {
        const view = event.currentTarget.dataset.view;
        this.dispatchEvent(new CustomEvent('navigate', { detail: { view } }));
    }
}

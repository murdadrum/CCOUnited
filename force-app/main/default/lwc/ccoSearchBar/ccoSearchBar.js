import { LightningElement, track } from 'lwc';

const DEBOUNCE_DELAY = 300;

export default class CcoSearchBar extends LightningElement {
    @track searchValue = '';
    _debounceTimer;

    handleChange(event) {
        this.searchValue = event.target.value;
        clearTimeout(this._debounceTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._debounceTimer = setTimeout(() => {
            this.dispatchEvent(new CustomEvent('search', { detail: { term: this.searchValue } }));
        }, DEBOUNCE_DELAY);
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            clearTimeout(this._debounceTimer);
            this.dispatchEvent(new CustomEvent('search', { detail: { term: this.searchValue } }));
        }
    }
}

import { LightningElement, api, track } from 'lwc';

const VIEW_GROUPS = 'GROUPS';
const VIEW_CATEGORIES = 'CATEGORIES';
const VIEW_ASSETS = 'ASSETS';
const VIEW_SEARCH = 'SEARCH';

export default class CcoAssetDirectory extends LightningElement {
    @api siteTitle = 'CCO United';
    @api siteSubtitle = 'Community Asset Directory';

    @track currentView = VIEW_GROUPS;
    @track selectedGroupId = null;
    @track selectedGroupName = null;
    @track selectedCategoryId = null;
    @track selectedCategoryName = null;
    @track searchTerm = null;
    @track filterGroupId = null;
    @track selectedAssetType = null;
    @track _mobileFilterOpen = false;

    get isViewGroups() { return this.currentView === VIEW_GROUPS; }
    get isViewCategories() { return this.currentView === VIEW_CATEGORIES; }
    get isViewAssets() { return this.currentView === VIEW_ASSETS; }
    get isViewSearch() { return this.currentView === VIEW_SEARCH; }

    get showBreadcrumb() {
        return this.currentView !== VIEW_GROUPS;
    }

    get filtersClass() {
        const base = 'cco-directory__filters';
        const isAssetOrSearch = this.isViewAssets || this.isViewSearch;
        return (isAssetOrSearch && !this._mobileFilterOpen)
            ? base + ' cco-directory__filters--hidden-mobile'
            : base;
    }

    get groupsBtnClass() {
        return 'cco-mobile-nav__btn' + (this.isViewGroups ? ' cco-mobile-nav__btn--active' : '');
    }

    get searchBtnClass() {
        return 'cco-mobile-nav__btn' + (this.isViewSearch ? ' cco-mobile-nav__btn--active' : '');
    }

    get filterBtnClass() {
        return 'cco-mobile-nav__btn' + (this._mobileFilterOpen ? ' cco-mobile-nav__btn--active' : '');
    }

    get breadcrumbs() {
        const crumbs = [{ label: 'CCO United', view: VIEW_GROUPS }];
        if (this.currentView === VIEW_CATEGORIES || this.currentView === VIEW_ASSETS) {
            crumbs.push({ label: this.selectedGroupName, view: VIEW_CATEGORIES });
        }
        if (this.currentView === VIEW_ASSETS && this.selectedCategoryName) {
            crumbs.push({ label: this.selectedCategoryName, view: null });
        }
        if (this.currentView === VIEW_SEARCH) {
            crumbs.push({ label: 'Search Results', view: null });
        }
        return crumbs;
    }

    handleGroupSelect(event) {
        this.selectedGroupId = event.detail.id;
        this.selectedGroupName = event.detail.name;
        this.currentView = VIEW_CATEGORIES;
        this._clearSearch();
    }

    handleCategorySelect(event) {
        this.selectedCategoryId = event.detail.id;
        this.selectedCategoryName = event.detail.name;
        this.currentView = VIEW_ASSETS;
        this._mobileFilterOpen = false;
    }

    handleSearch(event) {
        const term = event.detail.term;
        if (!term || term.trim().length === 0) {
            if (this.currentView === VIEW_SEARCH) {
                this.currentView = VIEW_GROUPS;
            }
            this.searchTerm = null;
            return;
        }
        this.searchTerm = term.trim();
        this.selectedCategoryId = null;
        this.selectedCategoryName = null;
        this.currentView = VIEW_SEARCH;
    }

    handleFilterChange(event) {
        const { groupId, assetType } = event.detail;
        this.filterGroupId = groupId || null;
        this.selectedAssetType = assetType || null;
    }

    handleBreadcrumbNavigate(event) {
        const view = event.detail.view;
        if (view === VIEW_GROUPS) {
            this._reset();
        } else if (view === VIEW_CATEGORIES) {
            this.selectedCategoryId = null;
            this.selectedCategoryName = null;
            this.currentView = VIEW_CATEGORIES;
        }
    }

    handleMobileGroups() {
        this._reset();
    }

    handleMobileSearch() {
        const searchBar = this.template.querySelector('c-cco-search-bar');
        if (searchBar) {
            searchBar.focus();
        }
    }

    handleMobileFilter() {
        this._mobileFilterOpen = !this._mobileFilterOpen;
    }

    _reset() {
        this.currentView = VIEW_GROUPS;
        this.selectedGroupId = null;
        this.selectedGroupName = null;
        this.selectedCategoryId = null;
        this.selectedCategoryName = null;
        this.filterGroupId = null;
        this.selectedAssetType = null;
        this._mobileFilterOpen = false;
        this._clearSearch();
    }

    _clearSearch() {
        this.searchTerm = null;
    }
}

import { LightningElement, api } from 'lwc';

export default class CcoHero extends LightningElement {
    @api title = 'CCO United';
    @api subtitle = 'Community Asset Directory';
    @api heroImageUrl;

    get heroStyle() {
        return this.heroImageUrl
            ? `background-image: url('${this.heroImageUrl}'); background-size: cover; background-position: center;`
            : '';
    }
}

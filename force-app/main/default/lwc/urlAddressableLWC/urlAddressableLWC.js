import { LightningElement, api } from 'lwc';
import EditAccountTeam from 'c/editAccountTeam';

export default class UrlAddressableLWC extends LightningElement {

    async openModal() {
        const result = await EditAccountTeam.open({
            size: 'large'
        });
        console.log(result);
    }

}
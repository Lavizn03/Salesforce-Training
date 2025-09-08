import { LightningElement, wire } from 'lwc';
import getAllObjects from '@salesforce/apex/ObjectService.getAllObjects';

export default class SalesforceallObjects extends LightningElement {
    objectOptions = [];
    selectedObject = '';
     
    @wire(getAllObjects)
    wiredObjects({data, error}){
        if(data){
            this.objectOptions = data.map(objectName => ({label: objectName, value: objectName}));
        }else if(error){
            console.error(error);}
    }

     handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        console.log('Selected Object:', this.selectedObject);
    }
}
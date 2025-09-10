import { LightningElement, wire,track } from 'lwc';
import getAllObjects from '@salesforce/apex/ObjectService.getAllObjects';
import getFieldsOfObject from '@salesforce/apex/ObjectService.getFieldsOfObject';
import getRecords from '@salesforce/apex/ObjectService.getRecords';
import updateRecords from '@salesforce/apex/ObjectService.updateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SalesforceallObjects extends LightningElement {
     objectOptions = [];
     selectedObject = '';
     @track objectFields = [];
    objectRecords = [];
     @track recordColumns = [];
     @track fieldOptions = [];
     @track selectedFieldAPIs = [];
     @track showFieldSelector = false;
     @track showData = [];
      draftValues = [];
     @track isModalOpen = false;
     currentOffset = 0;
     pageSize = 10;
      allRecordsLoaded = false;

    @wire(getAllObjects)
    wiredObjects({data, error}){
        if(data){
            this.objectOptions = data.map(objectName => ({label: objectName, value: objectName}));

        }else if(error){
            console.error(error);}
    }
    
     
      handleObjectSelection(event) {
        this.selectedObject = event.detail.value;
        this.selectedFieldAPIs = [];
        this.showData = [];
        this.objectRecords = [];
        this.recordColumns = [];
        this.currentOffset = 0;
        this.showFieldSelector= true;
        this.allRecordsLoaded = false;
        console.log('Selected Object:', this.selectedObject);

        getFieldsOfObject({objectApiName: this.selectedObject})
            .then(result=>{
                this.fieldOptions = result;
            this.showFieldSelector= true;
        })
            .catch((error)=>{
                console.error('Error getting object fields:', error);
            });
    }

    handleFieldSelection(event){
        this.selectedFieldAPIs= event.detail.value;
       console.log('Selected Fields:', JSON.stringify(this.selectedFieldAPIs));
    }
    handleFetchRecords(){
        this.isModalOpen = false;
         if (!this.selectedObject || this.selectedFieldAPIs.length === 0 ) {
        alert('Please select at least one field before fetching records.');
        return;
    }
         this.showFieldSelector= true;
         this.showData = [];
         this.objectRecords  = [];
         this.draftValues = [];
         this.currentOffset = 0;
          this.allRecordsLoaded=false;
        

        const selectedFieldObjects = this.fieldOptions.filter(opt =>
            this.selectedFieldAPIs.includes(opt.value)
        );

        this.recordColumns = selectedFieldObjects.map(field => {
            console.log('Mapping label: ' + field.label + ' name: ' + field.value + ' Updateable: ' + field.updateable);
            return {
                label: field.label,       
                fieldName: field.value,
                editable: field.updateable === 'true' ? true : false   
            };
        });



        // this.recordColumns = this.selectedFieldAPIs.map(fieldApiName => ({
        // label: fieldApiName,
        // fieldName: fieldApiName,
        // editable: fieldApiName.updateable==='true'? true:false
        //   }));
          this.fetchRecordsBatch();
    
    }

    fetchRecordsBatch(){
         getRecords({
            objectApiName: this.selectedObject,
            selectedFields: this.selectedFieldAPIs,
            offsetSize: this.currentOffset,
            limitSize: this.pageSize
        })
            .then(result => {
                if (result.length === 0 && this.showData.length === 0) {
                this.dispatchEvent(
                  new ShowToastEvent({
                title: 'No Records Found',
                message: `No records were found for ${this.selectedObject}.`,
                variant: 'info',
              })
            );
             this.allRecordsLoaded = true;
            return;
            }

                if (result.length < this.pageSize) {
                    this.allRecordsLoaded = true;
                }
                this.showData = [...this.showData, ...result];
                this.currentOffset += this.pageSize;

            })
            .catch(error => {
                console.error('Error getting records:', error);
            });
    }
    handleLoadMore(event){
        if (this.allRecordsLoaded) {
            event.target.enableInfiniteLoading = false;
            return;
        }
        this.fetchRecordsBatch();
        }
        openFieldModal() {
        this.isModalOpen = true;
    }

    closeFieldModal() {
        this.isModalOpen = false;
    }
     handleSave(event) {
          this.draftValues = event.detail.draftValues;
         console.log('Draft Values:', JSON.stringify(this.draftValues));

         updateRecords({ updatedRecords: this.draftValues })
          .then(result => {
            console.log(result);
            this.draftValues = [];
            this.currentOffset= 0;
            this.showData = [];
            this.fetchRecordsBatch();
             this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully!',
                    variant: 'success',
                })
            );
        })
        .catch(error => {
            console.error('Error updating records:', error);
             this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to update records. ' + error.body?.message,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
}

       

    }
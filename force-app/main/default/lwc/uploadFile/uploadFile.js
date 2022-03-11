import { LightningElement, api } from 'lwc';

export default class UploadFile extends LightningElement {
  @api recordId;
  allowedFileTypes = [".png", ".jpg", ".jpeg"];

  handleUploadFinished = (event) => {
    const uploaded = event.detail.files;
    console.log(uploaded)
  };
}
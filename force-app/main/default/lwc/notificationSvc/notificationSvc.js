import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const showNotification = (sourceComponent, variant, message, title, sticky) => {
    const mode = sticky ? 'sticky' : 'dismissable';
    let eventDetails = {
        title: title,
        message: message,
        variant: variant,
        mode: mode
    };
    if (sourceComponent.dispatchEvent) { //The source component is a LWC
        sourceComponent.dispatchEvent(new ShowToastEvent(eventDetails));
    } else if (sourceComponent.showToast) { //The source component is a notificationLibrary Aura component
        sourceComponent.showToast(eventDetails);
    } else {
        if (console) {
            console.error('Invalid source component');
        }
    }
};

const error = (sourceComponent, message, title, sticky) => {
    if (console) {
        console.error(message);
    }
    showNotification(sourceComponent, 'error', message, title, sticky);
};

const warn = (sourceComponent, message, title, sticky) => {
    if (console) {
        console.warn(message);
    }
    showNotification(sourceComponent, 'warning', message, title, sticky);
};

const info = (sourceComponent, message, title, sticky) => {
    if (console) {
        console.info(message);
    }
    showNotification(sourceComponent, 'info', message, title, sticky);
};

const success = (sourceComponent, message, title, sticky) => {
    if (console) {
        console.info(message);
    }
    showNotification(sourceComponent, 'success', message, title, sticky);
};


export {error, warn, info, success};
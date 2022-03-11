({
    savePdf: function (component, saveToRecord) {
        const action = component.get('c.savePdfToContentVersion')
        const recordId = component.get('v.recordId')
        const closeQuickAction = $A.get('e.force:closeQuickAction')
        action.setParams({ recordId, saveToRecord })
        action.setCallback(this, (response) => {
            const state = response.getState()
            if (state === 'SUCCESS') {
                const documentId = response.getReturnValue()
                const pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: documentId,
                        objectApiName: 'ContentDocument',
                        actionName: 'view',
                    },
                }
                const navService = component.find('navService')
                navService.navigate(pageReference)
                closeQuickAction.fire()
            } else if (state === 'ERROR') {
                const errors = response.getError()
                console.error(errors)
                closeQuickAction.fire()
            }
        })
        $A.enqueueAction(action)
    }
})
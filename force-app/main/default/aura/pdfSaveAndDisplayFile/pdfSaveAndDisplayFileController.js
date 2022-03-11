({
    handleSaveInRecord: function (component, event, helper) {
        helper.savePdf(component, true)
    },

    handleSaveInPdfs: function (component, event, helper) {
        helper.savePdf(component, false)
    }
})
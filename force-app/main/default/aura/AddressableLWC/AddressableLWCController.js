({
    init : function(component, event, helper) {
		let pageRef = component.get("v.pageReference");

		let encodedCompDef = btoa(
			JSON.stringify({
				componentDef: pageRef.state.c__lwc,
				attributes: pageRef.state
			})
		);

		component.find("navService").navigate(
			{
				type: "standard__webPage",
				attributes: {
					url: "/one/one.app#" + encodedCompDef
				}
			},
			true
		);
    }
})
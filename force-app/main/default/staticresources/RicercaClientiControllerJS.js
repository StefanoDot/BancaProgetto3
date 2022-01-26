var app = angular.module('app', []);

app.controller('RicercaClientiController', function($scope, $location) {
    $scope.filters = {ragioneSociale:null, partitaIva:null, codiceFiscale:null, telefono:null}
    $scope.accounts = [];
    $scope.paginatedAccounts = [];
    $scope.pages = [];
    $scope.noResults = false;
    
	$scope.getUrlParam = function(sParam) {
		var sPageURL = window.location.search.substring(1);
		var sURLVariables = sPageURL.split('&'); 
		//console.log('sURLVariables: ' + sURLVariables);
		for (var i = 0; i < sURLVariables.length; i++) {
			var sParameterName = sURLVariables[i].split('=');
			//console.log('parameter: ' + JSON.stringify(sParameterName));
			if (sParameterName[0] == sParam){
				return sParameterName[1];
			}
		}
		return null;
	}

	$scope.enter = function(keyEvent) {
         if (keyEvent.which === 13) {
              $scope.searchAccount();
         }
     }
    
   $scope.searchAccount = function() {
       $scope.showSpinner = true;
       $scope.accounts = [];
       $scope.paginatedAccounts = [];
       $scope.pages = [];
        $scope.noResults = false;

        Visualforce.remoting.Manager.invokeAction(
				'AccountsController.searchAccount',
            $scope.filters.ragioneSociale, $scope.filters.partitaIva, $scope.filters.codiceFiscale, $scope.filters.telefono,
				function(result, event){
                    console.log(result);
                    if(event.status){
                        if(result == null || result.length > 0) {
                            for(let i=0, k=0; i < result.length; i+=10, k++) {
                                let max = (i+10 <= result.length) ? i+10 : result.length;
                                let tmpArray = result.slice(i, max);
                                $scope.paginatedAccounts.push(tmpArray);
                                $scope.pages.push(k+1);
                            }
                            $scope.selectedPage = 1;
                            $scope.accounts = $scope.paginatedAccounts[$scope.selectedPage-1];
                        } else {
                            $scope.noResults = true;
                        }
                    }
                    $scope.showSpinner = false;
                    $scope.$apply();
				},
            {escape:false}
		);
    }
        

    $scope.go = function(acc){
        if((typeof sforce != 'undefined') && sforce && (!!sforce.one) )
           	sforce.one.navigateToURL(encodeURI('/'+acc.account.Id));
        else
            window.location.href = '/'+acc.account.Id;
	}

	$scope.createNewAccount = function(url){
           if(url == "dev-bancaprogetto.cs105.force.com") {
                window.parent.location.href = '/s/account/Account/00B1t0000075P5VEAU';
           } else {
               if((typeof sforce != 'undefined') && sforce && (!!sforce.one) ) {
                   let defaultValues = {};
                   if($scope.filters.ragioneSociale != null && $scope.filters.ragioneSociale != '') {
                       defaultValues.Name = $scope.filters.ragioneSociale;
                   }
                   if($scope.filters.partitaIva != null && $scope.filters.partitaIva != '') {
                      defaultValues.Partita_Iva__c = $scope.filters.partitaIva;
                  }
                  if($scope.filters.codiceFiscale != null && $scope.filters.codiceFiscale != '') {
                      defaultValues.Codice_Fiscale__c = $scope.filters.codiceFiscale;
                  }

                  if($scope.filters.telefono != null && $scope.filters.telefono != '') {
                     defaultValues.Phone = $scope.filters.telefono;
                 }

                  sforce.one.createRecord('Account', null, defaultValues);
                } else {
                    window.location.href = '/001/e?';
                }
            }
    	}

	$scope.assignToMe = function(acc){
	    $scope.showSpinner = true;
          Visualforce.remoting.Manager.invokeAction(
                'AccountsController.assignToCurrentUser',
              acc.account.Id,
                function(result, event){
                   if(event.status){
                     $scope.showSpinner = false;
                     acc.account.Owner = {};
                     acc.account.Owner.Name = result;
                     acc.action = 1;
                   }
                   $scope.$apply();
                },
              {escape:false}
        );
    }

    $scope.goToPage = function(page){
        if(page > 0 && page <= $scope.pages.length) {
            $scope.selectedPage = page;
            $scope.accounts = $scope.paginatedAccounts[$scope.selectedPage-1];
        }
    }


});

// Generated by CoffeeScript 1.10.0
angular.module('EarthDollarWallet', []).controller('EarthDollarCtrl', function($scope, $interval) {
  var account, dialog, i, j, k, len, ref, ref1, updateBalances;
  $scope.minterAccounts = [];
  $scope.amount = 0;
  $scope.recipientAddress = '';
  dialog = $('#modal');
  $scope.accounts = [];
  ref = web3.eth.accounts;
  for (j = 0, len = ref.length; j < len; j++) {
    account = ref[j];
    $scope.accounts.push({
      address: account,
      amount: parseInt(EarthDollarWallets.coinBalance.call({
        from: account
      }))
    });
    for (i = k = 0, ref1 = EarthDollarWallets.numMinters.call(); k <= ref1; i = k += 1) {
      if (EarthDollarWallets.minterAt(i) === account) {
        $scope.isMinter = true;
        $scope.minterAccounts.push(account);
      }
    }
  }
  updateBalances = function() {
    var entry, l, len1, ref2, results;
    ref2 = web3.eth.accounts;
    results = [];
    for (l = 0, len1 = ref2.length; l < len1; l++) {
      account = ref2[l];
      results.push((function() {
        var len2, m, ref3, results1;
        ref3 = $scope.accounts;
        results1 = [];
        for (m = 0, len2 = ref3.length; m < len2; m++) {
          entry = ref3[m];
          if (account === entry.address) {
            results1.push(entry.amount = parseInt(EarthDollarWallets.coinBalance.call({
              from: account
            })));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      })());
    }
    return results;
  };
  $interval(updateBalances, 1000);
  $scope.send = function(from, to, amount) {
    return EarthDollarWallets.sendCoin(amount, to, {
      from: from
    });
  };
  $scope.showMintDialog = function() {
    $scope.modalHeader = 'Mint coins';
    $scope.modalMode = 'mint';
    return dialog.modal();
  };
  $scope.showSendDialog = function(from) {
    $scope.modalHeader = 'Send coins from ' + from;
    $scope.modalMode = 'send';
    $scope.modalFrom = from;
    return dialog.modal();
  };
  return $scope.dialogOkButton = function() {
    if ($scope.modalMode === 'mint') {
      EarthDollarWallets.mintCoin($scope.amount, $scope.recipientAddress, {
        from: $scope.minterAccounts[0],
        gas: 100000
      });
    }
    if ($scope.modalMode === 'send') {
      EarthDollarWallets.sendCoin($scope.amount, $scope.recipientAddress, {
        from: $scope.modalFrom,
        gas: 100000
      });
    }
    return dialog.modal('hide');
  };
});
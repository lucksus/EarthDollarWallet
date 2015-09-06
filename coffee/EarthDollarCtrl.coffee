angular.module('EarthDollarWallet', [])
  .controller 'EarthDollarCtrl', ($scope, $interval)->
    $scope.minterAccounts = []
    $scope.amount = 0
    $scope.recipientAddress = ''
    dialog = $('#modal')


    $scope.accounts = []

    for account in web3.eth.accounts
      $scope.accounts.push {
          address: account,
          amount: parseInt(EarthDollarWallets.coinBalance.call({from: account}))
        }
      for i in [0..EarthDollarWallets.numMinters.call()] by 1
        if EarthDollarWallets.minterAt.call(i, {from: account}) == account
          $scope.isMinter = true
          $scope.minterAccounts.push account

    updateBalances = () ->
      for account in web3.eth.accounts
        for entry in $scope.accounts
          if account == entry.address
            entry.amount = parseInt(EarthDollarWallets.coinBalance.call({from: account}))

    $interval updateBalances, 1000



    $scope.send = (from, to, amount) ->
      EarthDollarWallets.sendCoin(amount, to, {from: from})

    $scope.showMintDialog = () ->
      $scope.modalHeader = 'Mint coins'
      $scope.modalMode = 'mint'
      dialog.modal()

    $scope.showSendDialog = (from) ->
      $scope.modalHeader = 'Send coins from ' + from
      $scope.modalMode = 'send'
      $scope.modalFrom = from
      dialog.modal()

    $scope.dialogOkButton = () ->
      if $scope.modalMode == 'mint'
        EarthDollarWallets.mintCoin($scope.amount, $scope.recipientAddress, {from: $scope.minterAccounts[0], gas: 100000})
      if $scope.modalMode == 'send'
        EarthDollarWallets.sendCoin($scope.amount, $scope.recipientAddress, {from: $scope.modalFrom, gas: 100000})
      dialog.modal('hide')

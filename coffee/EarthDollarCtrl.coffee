Web3 = require 'web3'
angular.module('EarthDollarWallet', [])
  .controller 'EarthDollarCtrl', ($scope, $interval)->
    $scope.minterAccounts = []
    $scope.amount = 0
    $scope.recipientAddress = ''
    dialog = $('#modal')
    $scope.accounts = []
    checkWeb3 = ->
      $scope.hasWeb3 = (typeof web3) != "undefined"
    checkWeb3()
    $scope.settled = false
    @EarthDollarWallets = {}



    connect = () ->
      console.log(web3, typeof web3)

      #if typeof web3 != 'undefined'
      #  web3 = new Web3(web3.currentProvider)
      #else
      #  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"))

      web3.eth.defaultAccount = web3.eth.accounts[0];
      EarthDollarWalletsAbi = [{"constant":false,"inputs":[{"name":"minterToRemove","type":"address"}],"name":"removeMinter","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"},{"name":"_to","type":"address"}],"name":"mintCoin","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"index","type":"uint256"}],"name":"minterAt","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_value","type":"uint256"},{"name":"_to","type":"address"}],"name":"sendCoinFrom","outputs":[{"name":"_success","type":"bool"}],"type":"function"},{"constant":false,"inputs":[{"name":"newMinter","type":"address"}],"name":"addMinter","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"changeOwner","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_addr","type":"address"}],"name":"coinBalanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_value","type":"uint256"},{"name":"_to","type":"address"}],"name":"sendCoin","outputs":[{"name":"_success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"coinBalance","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"numMinters","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"sender","type":"address"},{"indexed":false,"name":"receiver","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"CoinTransfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"receiver","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"CoinMinted","type":"event"}];
      EarthDollarWalletsContract = web3.eth.contract(EarthDollarWalletsAbi);
      @EarthDollarWallets = EarthDollarWalletsContract.at('0x449c5b639e9852ada644ffaacfe325dfce6e6e0a');
      for account in web3.eth.accounts
        $scope.accounts.push {
            address: account,
            amount: parseInt(EarthDollarWallets.coinBalance.call({from: account}))
          }
        for i in [0..EarthDollarWallets.numMinters.call()] by 1
          if EarthDollarWallets.minterAt.call(i, {from: account}) == account
            $scope.isMinter = true
            $scope.minterAccounts.push account


    updateBalances = () =>
      checkWeb3()
      return unless $scope.hasWeb3

      unless web3.isConnected()
        connect()
        return
      for account in web3.eth.accounts
        found = false
        for entry in $scope.accounts
          if account == entry.address
            entry.amount = parseInt(EarthDollarWallets.coinBalance.call({from: account}))
            found = true


    $interval updateBalances, 1000
    $interval ->
      $scope.settled=true
    , 2000, 1



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

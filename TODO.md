The TODO list
=============

(Perhaps change this into an emacs org-mode TODO file)

The list of things that needs done. Feel free to take anything on the
list if you want, but do coordinate so we don't do multiple work on
the same thing. Feel free to add anything to the list as well. It
partially acts like a bug tracker at the moment in addition to being a
wish-list.

    * Change the sender Queue into having two queues, one for short
      messages and one for long messages.
    * hFlush on the sender queue in the sender process, intelligently.
      There is no reason to flush the queue before we are fairly sure
      we got all the small messages into it. It is dependent on the
      above part.
    * Optimize reading of blocks by moving it to the sender Process in
      The Peer Process
    * Don't connect twice to the same client id. Track the clients we
      connected to.
    * Make it possible to Poison OMBox'es. Currently we leak due to them.
    * Handle error cases when checking a torrent file.
    * Add support for DHT
    * Add support for multiple files
    * Add rate limitation support, locally or globally
    * Add leeching support
    * Add support for multiple torrents at once
    * Add prioritization support of multiTorrents
    * Support the FAST extension
    * Support UDP tracking extension
    * Support partial downloads (select files you want in the torrent)
    * Write an ETA estimator
    * Implement a creator for torrent files
    * Implement a scraper on trackers
    * Turn the logging system into a better framework, add log levels,
      add process names so we can see who is doing what.
    * If we get a wrong URI, the code currently deadlocks since the tracker
      dies. Handle this problem gracefully.
    * Cleanup the BCode module, while keeping the interface somewhat
      stable. The code is an utter mess as it stands right now.
    * Improve the cabal file for the project, check with GHC 6.12.1,
      provide correct versions of needed packages.
    * Implement the PieceManager code; the documentation explains what it
      must do.
    * Make the client into an eligible leecher.
    * Consider David Himmelstrups work in the packages bencode, torrent
      In the long run it would be beneficial. Short term, there is less need
      for the integration.
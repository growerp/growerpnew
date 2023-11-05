/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

part of 'ledger_journal_bloc.dart';

abstract class LedgerJournalEvent extends Equatable {
  const LedgerJournalEvent();
  @override
  List<Object> get props => [];
}

class LedgerJournalFetch extends LedgerJournalEvent {
  const LedgerJournalFetch(
      {this.searchString = '', this.refresh = false, this.limit = 20});
  final String searchString;
  final bool refresh;
  final int limit;
  @override
  List<Object> get props => [searchString, refresh];
}

class LedgerJournalUpdate extends LedgerJournalEvent {
  const LedgerJournalUpdate(this.ledgerJournal);
  final LedgerJournal ledgerJournal;
}

class LedgerJournalDelete extends LedgerJournalEvent {
  const LedgerJournalDelete(this.ledgerJournal);
  final LedgerJournal ledgerJournal;
}

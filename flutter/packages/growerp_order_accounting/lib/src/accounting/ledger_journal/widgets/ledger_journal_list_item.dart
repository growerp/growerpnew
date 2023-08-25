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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_order_accounting/growerp_order_accounting.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LedgerJournalListItem extends StatelessWidget {
  const LedgerJournalListItem(
      {Key? key, required this.ledgerJournal, required this.index})
      : super(key: key);

  final LedgerJournal ledgerJournal;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ledgerJournalBloc = context.read<LedgerJournalBloc>();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(ledgerJournal.journalName.isEmpty ? '?' : ''),
      ),
      title: Column(children: [
        if (ResponsiveBreakpoints.of(context).isMobile)
          Text(ledgerJournal.journalName),
        Row(
          children: <Widget>[
            if (ResponsiveBreakpoints.of(context).largerThan(MOBILE))
              Expanded(
                  child:
                      Text(ledgerJournal.journalName, key: Key('name$index'))),
            Expanded(
                child: Text(
                    ledgerJournal.postedDate == null
                        ? ''
                        : ledgerJournal.postedDate.toString(),
                    key: Key('postedDate$index'),
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text(ledgerJournal.isPosted == true ? 'Y' : 'N',
                    key: Key('isPosted$index'), textAlign: TextAlign.center)),
            Expanded(
                child: Text(ledgerJournal.isError == true ? 'Y' : 'N',
                    key: Key('isError$index'), textAlign: TextAlign.left)),
          ],
        )
      ]),
      onTap: () async {
        await showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext context) => BlocProvider.value(
                value: ledgerJournalBloc,
                child: LedgerJournalDialog(ledgerJournal)));
      },
      trailing: GestureDetector(
        child: const Text(
          'POST',
        ),
        onTap: () async {
          if (ledgerJournal.isPosted == false) {
            ledgerJournalBloc.add(
                LedgerJournalUpdate(ledgerJournal.copyWith(isPosted: true)));
          }
        },
      ),
    );
  }
}

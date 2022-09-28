(* Sync_Core2 module for Augeas
 Author: Yurii Anisimov <ays@rssib.ru>

 cash.ini is a standard INI File.
*)


module Sync_Core2 =
  autoload xfm

(************************************************************************
 * INI File settings
 *
 * cash.ini only supports "; as commentary and "=" as separator
 *************************************************************************)
let comment    = IniFile.comment ";" ";"
let sep        = IniFile.sep "=" "="


(************************************************************************
 *                        ENTRY
 * cash.ini uses standard INI File entries
 *************************************************************************)
let entry   = IniFile.indented_entry IniFile.entry_re sep comment


(************************************************************************
 *                        RECORD
 * cash.ini uses standard INI File records
 *************************************************************************)
let title   = IniFile.indented_title IniFile.record_re
let record  = IniFile.record title entry


(************************************************************************
 *                        LENS & FILTER
 * cash.ini uses standard INI File records
 *************************************************************************)
let lns     = IniFile.lns record comment

let filter = (incl "/linuxcash/cash/sync/properties/cash.ini")

let xfm = transform lns filter

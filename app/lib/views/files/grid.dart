import 'dart:typed_data';

import 'package:butterfly/api/file_system.dart';
import 'package:butterfly_api/butterfly_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lw_file_system/lw_file_system.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FileEntityGridItem extends StatelessWidget {
  final String? modifiedText, createdText;
  final bool active, editable, collapsed;
  final bool? selected;
  final Widget actionButton;
  final PhosphorIconData icon;
  final VoidCallback onTap, onDelete, onReload;
  final ValueChanged<bool> onEdit, onSelectedChanged;
  final Uint8List? thumbnail;
  final FileSystemEntity<NoteData> entity;
  final TextEditingController nameController;

  const FileEntityGridItem({
    super.key,
    this.createdText,
    this.modifiedText,
    this.selected = false,
    this.active = false,
    this.editable = false,
    this.collapsed = false,
    required this.actionButton,
    required this.icon,
    required this.onTap,
    required this.onDelete,
    required this.onReload,
    required this.onEdit,
    required this.onSelectedChanged,
    this.thumbnail,
    required this.entity,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileSystem = context.read<ButterflyFileSystem>();
    final settingsCubit = fileSystem.settingsCubit;
    final remote = settingsCubit.getRemote(entity.location.remote);
    final documentSystem = fileSystem.buildDocumentSystem(remote);
    final leading = PhosphorIcon(
      icon,
      color: colorScheme.outline,
      size: 48,
    );
    return Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: active
              ? BorderSide(
                  color: colorScheme.primaryContainer,
                  width: 1,
                )
              : BorderSide.none,
        ),
        surfaceTintColor: active
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onTap,
          highlightColor: active ? colorScheme.primaryContainer : null,
          child: SizedBox(
            width: 160,
            height: 192,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 96,
                        width: 96,
                        padding: const EdgeInsets.only(top: 8),
                        child: thumbnail != null
                            ? Image.memory(
                                thumbnail!,
                                fit: BoxFit.contain,
                                cacheWidth: 96,
                                cacheHeight: 96,
                                errorBuilder: (context, error, stackTrace) =>
                                    leading,
                              )
                            : leading,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: actionButton,
                    ),
                    if (selected != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Checkbox(
                          value: selected,
                          onChanged: (value) =>
                              onSelectedChanged(value ?? false),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 16,
                          child: modifiedText != null
                              ? Tooltip(
                                  message:
                                      AppLocalizations.of(context).modified,
                                  child: Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIconsLight
                                            .clockCounterClockwise,
                                        size: 12,
                                        color: colorScheme.outline,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        modifiedText!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(
                          height: 16,
                          child: createdText != null
                              ? Tooltip(
                                  message: AppLocalizations.of(context).created,
                                  child: Row(
                                    children: [
                                      PhosphorIcon(
                                        PhosphorIconsLight.plus,
                                        size: 12,
                                        color: colorScheme.outline,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        createdText!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme.outline,
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 32,
                          child: editable
                              ? ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: TextField(
                                    controller: nameController,
                                    autofocus: true,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                    onSubmitted: (value) async {
                                      await documentSystem.renameAsset(
                                          entity.location.path, value);
                                      onEdit(false);
                                      onReload();
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      hintText: AppLocalizations.of(context)
                                          .enterText,
                                      suffix: IconButton(
                                        onPressed: () async {
                                          await documentSystem.renameAsset(
                                              entity.location.path,
                                              nameController.text);
                                          onEdit(false);
                                          onReload();
                                        },
                                        icon: const PhosphorIcon(
                                            PhosphorIconsLight.check),
                                        tooltip:
                                            AppLocalizations.of(context).save,
                                      ),
                                    ),
                                  ))
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Tooltip(
                                    message: entity.fileName,
                                    child: GestureDetector(
                                      child: Text(
                                        entity.fileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      onDoubleTap: () {
                                        onEdit(true);
                                        nameController.text = entity.fileName;
                                      },
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

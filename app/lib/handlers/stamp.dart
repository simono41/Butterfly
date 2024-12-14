part of 'handler.dart';

class StampHandler extends PastingHandler<StampTool> {
  ButterflyComponent? _component;
  Offset _position = Offset.zero;
  Rect rect = Rect.zero;
  List<Renderer<PadElement>>? _elements;
  StampHandler(super.data);

  @override
  List<Renderer> createForegrounds(CurrentIndexCubit currentIndexCubit,
          NoteData document, DocumentPage page, DocumentInfo info,
          [Area? currentArea]) =>
      [
        ...super.createForegrounds(
            currentIndexCubit, document, page, info, currentArea),
        if (!currentlyPasting)
          ...transformElements(Rect.fromPoints(_position, _position), '')
              .map(Renderer.fromInstance),
      ];

  void _update(PointerEvent event, EventContext context) {
    final state = context.getState();
    if (state != null) {
      _loadComponent(state.data, state.assetService, state.page);
    }
    _position = context.getCameraTransform().localToGlobal(event.localPosition);
    context.refresh();
  }

  @override
  void onPointerHover(PointerHoverEvent event, EventContext context) =>
      _update(event, context);

  @override
  void onPointerDown(PointerDownEvent event, EventContext context) {
    _update(event, context);
    super.onPointerDown(event, context);
  }

  ButterflyComponent? getComponent(NoteData document) =>
      document.getPack(data.component.pack)?.getComponent(data.component.name);

  Future<void> _loadComponent(
      NoteData document, AssetService assetService, DocumentPage page,
      [bool force = false]) async {
    _position = Offset.zero;
    _component = getComponent(document);
    if ((!force && _elements != null) || _component == null) return;
    _elements = await Future.wait(
        _component?.elements.map(Renderer.fromInstance).map((e) async {
              await e.setup(document, assetService, page);
              return e;
            }) ??
            []);
    Rect? rect;
    for (final e in _elements!) {
      final r = e.rect;
      if (r == null) continue;
      if (rect == null) {
        rect = r;
      } else {
        rect = rect.expandToInclude(r);
      }
    }
    if (rect != null) {
      this.rect = rect;
    }
  }

  @override
  PreferredSizeWidget getToolbar(DocumentBloc bloc) => ComponentsToolbarView(
        component: data.component,
        onChanged: (value) {
          final state = bloc.state;
          if (state is! DocumentLoaded) return;
          bloc.add(ToolsChanged({
            state.info.tools.indexOf(data): data.copyWith(
              component: value,
            ),
          }));
        },
      );
  @override
  MouseCursor get cursor => SystemMouseCursors.click;

  @override
  List<PadElement> transformElements(Rect rect, String collection) {
    var scaleX = 1.0, scaleY = 1.0;
    if (!rect.isEmpty && !this.rect.isEmpty) {
      scaleX = rect.width / this.rect.width;
      scaleY = rect.height / this.rect.height;
    }
    return _elements
            ?.map((e) =>
                e
                    .transform(
                        position: rect.topLeft,
                        scaleX: scaleX,
                        scaleY: scaleY,
                        relative: true)
                    ?.element ??
                e.element)
                .map((e) => e.copyWith(id: createUniqueId()))
            .toList() ??
        [];
  }
}

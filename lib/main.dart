
import 'package:flutter/material.dart';
import 'package:kjg_qr_code_generator/util/localization_extension.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'features/save_image_web.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const KjGQrCodeGeneratorApp());
}

class KjGQrCodeGeneratorApp extends StatelessWidget {
  const KjGQrCodeGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "KjG QR-Code Generator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late QrImage qrImage;

  late PrettyQrDecoration decoration;

  @override
  void initState() {
    super.initState();

    qrImage = QrImage(QrCode.fromData(
      data: 'https://muenchen.kjg.de/',
      errorCorrectLevel: QrErrorCorrectLevel.H,
    ));

    decoration = const PrettyQrDecoration(
      background: Colors.transparent,
      quietZone: PrettyQrQuietZone.zero,
      shape: PrettyQrSquaresSymbol()
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.localizations;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(loc.title),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1024,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safePadding = MediaQuery.of(context).padding;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.maxWidth >= 720)
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: safePadding.left + 24,
                          right: safePadding.right + 24,
                          bottom: 24,
                        ),
                        child: _PrettyQrAnimatedView(
                          qrImage: qrImage,
                          decoration: decoration,
                        ),
                      ),
                    ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        if (constraints.maxWidth < 720)
                          Padding(
                            padding: safePadding.copyWith(
                              top: 0,
                              bottom: 0,
                            ),
                            child: _PrettyQrAnimatedView(
                              qrImage: qrImage,
                              decoration: decoration,
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: safePadding.copyWith(top: 0),
                            child: _PrettyQrSettings(
                              decoration: decoration,
                              onChanged: (value) => setState(() {
                                decoration = value;
                              }),
                              onExportPressed: (size) {
                                return qrImage.exportAsImage(
                                  context,
                                  size: size,
                                  decoration: decoration,
                                );
                              },
                              onUrlChanged: (url) => setState(() {
                                qrImage = QrImage(QrCode.fromData(
                                  data: url,
                                  errorCorrectLevel: QrErrorCorrectLevel.H,
                                ));
                              }),
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PrettyQrAnimatedView extends StatefulWidget {
  final QrImage qrImage;
  final PrettyQrDecoration decoration;

  const _PrettyQrAnimatedView({
    required this.qrImage,
    required this.decoration,
  });

  @override
  State<_PrettyQrAnimatedView> createState() => _PrettyQrAnimatedViewState();
}

class _PrettyQrAnimatedViewState extends State<_PrettyQrAnimatedView> {
  late PrettyQrDecoration previousDecoration;

  @override
  void initState() {
    super.initState();
    previousDecoration = widget.decoration;
  }

  @override
  void didUpdateWidget(
      covariant _PrettyQrAnimatedView oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (widget.decoration != oldWidget.decoration) {
      previousDecoration = oldWidget.decoration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TweenAnimationBuilder<PrettyQrDecoration>(
        tween: PrettyQrDecorationTween(
          begin: previousDecoration,
          end: widget.decoration,
        ),
        curve: Curves.ease,
        duration: const Duration(
          milliseconds: 240,
        ),
        builder: (context, decoration, child) {
          return PrettyQrView(
            key: ValueKey(widget.qrImage),
            qrImage: widget.qrImage,
            decoration: decoration,
          );
        },
      ),
    );
  }
}

class _PrettyQrSettings extends StatefulWidget {
  final PrettyQrDecoration decoration;
  final Future<String?> Function(int)? onExportPressed;
  final ValueChanged<PrettyQrDecoration>? onChanged;
  final ValueChanged<String>? onUrlChanged;

  static const kDefaultQrDecorationImage = PrettyQrDecorationImage(
    image: AssetImage('assets/seelenbohrer.png'),
    padding: EdgeInsets.all(8),
    position: PrettyQrDecorationImagePosition.embedded,
  );

  const _PrettyQrSettings({
    required this.decoration,
    this.onChanged,
    this.onExportPressed,
    this.onUrlChanged,
  });

  @override
  State<_PrettyQrSettings> createState() => _PrettyQrSettingsState();
}

class _PrettyQrSettingsState extends State<_PrettyQrSettings> {
  late final TextEditingController urlEditingController;
  late final TextEditingController imageSizeEditingController;

  @override
  void initState() {
    super.initState();

    urlEditingController = TextEditingController(text: 'https://muenchen.kjg.de/');
    imageSizeEditingController = TextEditingController(
      text: ' 512w',
    );
  }

  int get imageSize {
    final rawValue = imageSizeEditingController.text;
    return int.parse(rawValue.replaceAll('w', '').replaceAll(' ', ''));
  }

  void showExportPath(String? path) {
    final loc = context.localizations;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path == null ? loc.downloading : 'Saved to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.localizations;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.link_outlined),
          title: TextField(
            controller: urlEditingController,
            decoration: InputDecoration(
              labelText: loc.url,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.url,
            onChanged: (value) {
              if (value.isNotEmpty) {
                widget.onUrlChanged?.call(value);
              }
            },
          ),
        ),
        const Divider(),
        SwitchListTile.adaptive(
          value: widget.decoration.image != null,
          onChanged: (value) => toggleImage(),
          secondary: Icon(
            widget.decoration.image != null
                ? Icons.image_outlined
                : Icons.hide_image_outlined,
          ),
          title: Text(context.localizations.kjg_logo),
        ),
        if (widget.onExportPressed != null) ...[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: Text(loc.download),
            onTap: () async {
              final path = await widget.onExportPressed?.call(imageSize);
              showExportPath(path);
            },
            trailing: PopupMenuButton(
              initialValue: imageSize,
              onSelected: (value) {
                imageSizeEditingController.text = ' ${value}w';
                setState(() {});
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 256,
                    child: Text('256w'),
                  ),
                  const PopupMenuItem(
                    value: 512,
                    child: Text('512w'),
                  ),
                  const PopupMenuItem(
                    value: 1024,
                    child: Text('1024w'),
                  ),
                ];
              },
              child: SizedBox(
                width: 72,
                height: 36,
                child: TextField(
                  enabled: false,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                  controller: imageSizeEditingController,
                  decoration: InputDecoration(
                    filled: true,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    fillColor: Theme.of(context).colorScheme.surface,
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void toggleImage() {
    const defaultImage = _PrettyQrSettings.kDefaultQrDecorationImage;
    final image = widget.decoration.image != null ? null : defaultImage;

    widget.onChanged?.call(PrettyQrDecoration(
      image: image,
      shape: widget.decoration.shape,
      quietZone: widget.decoration.quietZone,
      background: widget.decoration.background,
    ));
  }


  @override
  void dispose() {
    urlEditingController.dispose();
    imageSizeEditingController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// class MintScreen extends ConsumerStatefulWidget {
//   const MintScreen({super.key});

//   @override
//   ConsumerState<MintScreen> createState() => _MintScreenState();
// }

// class _MintScreenState extends ConsumerState<MintScreen> {
//   final TextEditingController _mintUrlController = TextEditingController();
//   bool _isConnecting = false;
//   String? _errorMessage;
//   bool _isConnected = false;

//   @override
//   void dispose() {
//     _mintUrlController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final walletState = ref.watch(walletProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Cashu Mint')),
//       body: _buildBody(walletState),
//     );
//   }

//   Widget _buildBody(WalletState state) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const Text(
//             'Connect to a Cashu Mint',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Enter a Cashu mint URL to connect and receive tokens',
//             style: TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 32),

//           // Current mint info
//           if (state.mintUrl != null && state.mintUrl!.isNotEmpty) ...[
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Current Mint',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.check_circle,
//                           color: Colors.green,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             state.mintUrl!,
//                             style: const TextStyle(fontFamily: 'monospace'),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.copy, size: 18),
//                           onPressed: () {
//                             Clipboard.setData(
//                               ClipboardData(text: state.mintUrl!),
//                             ).then((_) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Mint URL copied'),
//                                 ),
//                               );
//                             });
//                           },
//                           tooltip: 'Copy mint URL',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],

//           // Mint connection form
//           TextField(
//             controller: _mintUrlController,
//             decoration: InputDecoration(
//               labelText: 'Mint URL',
//               hintText: 'https://mint.example.com',
//               border: const OutlineInputBorder(),
//               errorText: _errorMessage,
//               prefixIcon: const Icon(Icons.link),
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   _mintUrlController.clear();
//                 },
//               ),
//             ),
//             keyboardType: TextInputType.url,
//             enabled: !_isConnecting,
//           ),
//           const SizedBox(height: 24),
//           if (_isConnecting)
//             const Center(child: CircularProgressIndicator())
//           else
//             ElevatedButton.icon(
//               onPressed: _connectToMint,
//               icon: const Icon(Icons.link),
//               label: const Text('Connect to Mint'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),

//           if (_isConnected) ...[
//             const SizedBox(height: 24),
//             const Card(
//               color: Colors.green,
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.white),
//                     SizedBox(width: 16),
//                     Expanded(
//                       child: Text(
//                         'Connected successfully! You can now receive tokens from this mint.',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           const Spacer(),

//           // Info card
//           const Card(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'About Cashu Mints',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Cashu is a token-based ecash system. Mints are servers that issue and redeem tokens. '
//                     'Connect to a mint to receive tokens and use them for payments. '
//                     'Only connect to mints you trust.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _connectToMint() async {
//     final url = _mintUrlController.text.trim();

//     if (url.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter a mint URL';
//       });
//       return;
//     }

//     if (!url.startsWith('http://') && !url.startsWith('https://')) {
//       setState(() {
//         _errorMessage = 'URL must start with http:// or https://';
//       });
//       return;
//     }

//     setState(() {
//       _isConnecting = true;
//       _errorMessage = null;
//       _isConnected = false;
//     });

//     try {
//       // Connect to the mint
//       final walletNotifier = ref.read(walletProvider.notifier);
//       await walletNotifier.connectToMint(url);

//       setState(() {
//         _isConnecting = false;
//         _isConnected = true;
//       });

//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Connected to mint successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isConnecting = false;
//         _errorMessage = 'Failed to connect: ${e.toString()}';
//       });
//     }
//   }
// }

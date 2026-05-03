import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF16A34A);
  static const lightGreen = Color(0xFFDCFCE7);
  static const background = Color(0xFFF8FAFC);
  static const darkText = Color(0xFF1E293B);
  static const grayText = Color(0xFF64748B);
  static const red = Color(0xFFEF4444);
  static const blue = Color(0xFF3B82F6);
}

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String date;
  final String note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      date: json['date'],
      note: json['note'],
    );
  }
}

class FinanceTip {
  final String title;
  final String description;

  FinanceTip({
    required this.title,
    required this.description,
  });

  factory FinanceTip.fromJson(Map<String, dynamic> json) {
    return FinanceTip(
      title: json['title'],
      description: json['description'],
    );
  }
}

class TransactionStorage {
  static const String key = 'transactions';

  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((item) => TransactionModel.fromJson(jsonDecode(item)))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> saveTransaction(TransactionModel transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    data.add(jsonEncode(transaction.toJson()));
    await prefs.setStringList(key, data);
  }

  static Future<void> deleteTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    final updatedData = data.where((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] != id;
    }).toList();

    await prefs.setStringList(key, updatedData);
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MoneyMate',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola uang mahasiswa dengan mudah',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardPage(),
    AddTransactionPage(),
    HistoryPage(),
    TipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        indicatorColor: AppColors.lightGreen,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
            label: 'Tambah',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.tips_and_updates_outlined),
            selectedIcon: Icon(Icons.tips_and_updates, color: AppColors.primary),
            label: 'Tips',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await TransactionStorage.getTransactions();

    setState(() {
      transactions = data;
    });
  }

  double get totalIncome {
    return transactions
        .where((item) => item.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return transactions
        .where((item) => item.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    final recentTransactions = transactions.take(4).toList();

    return RefreshIndicator(
      onRefresh: loadTransactions,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 28),
          Text(
            'Halo, Mahasiswa 👋',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'MoneyMate',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xFF22C55E),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 18),
                Text(
                  'Saldo Saat Ini',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatCurrency(balance),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Pemasukan',
                  amount: formatCurrency(totalIncome),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SummaryCard(
                  title: 'Pengeluaran',
                  amount: formatCurrency(totalExpense),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                onPressed: loadTransactions,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTransactions.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada transaksi',
              subtitle: 'Tambahkan pemasukan atau pengeluaran pertamamu.',
            )
          else
            ...recentTransactions.map(
                  (item) => TransactionItem(
                transaction: item,
                onDelete: () async {
                  await TransactionStorage.deleteTransaction(item.id);
                  loadTransactions();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = 'expense';
  String category = 'Makan';

  final List<String> incomeCategories = [
    'Uang Saku',
    'Beasiswa',
    'Freelance',
    'Bonus',
    'Lainnya',
  ];

  final List<String> expenseCategories = [
    'Makan',
    'Transportasi',
    'Kuliah',
    'Hiburan',
    'Belanja',
    'Lainnya',
  ];

  List<String> get activeCategories {
    return type == 'income' ? incomeCategories : expenseCategories;
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate()) return;

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      amount: double.parse(amountController.text.trim()),
      type: type,
      category: category,
      date: DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now()),
      note: noteController.text.trim(),
    );

    await TransactionStorage.saveTransaction(transaction);

    titleController.clear();
    amountController.clear();
    noteController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil disimpan'),
        backgroundColor: AppColors.primary,
      ),
    );

    setState(() {
      type = 'expense';
      category = 'Makan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 28),
        Text(
          'Tambah Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Catat pemasukan dan pengeluaranmu.',
          style: GoogleFonts.poppins(
            color: AppColors.grayText,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: inputDecoration(
                    label: 'Judul transaksi',
                    icon: Icons.edit_note_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Judul transaksi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration(
                    label: 'Nominal',
                    icon: Icons.payments_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nominal wajib diisi';
                    }

                    if (double.tryParse(value.trim()) == null) {
                      return 'Nominal harus berupa angka';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: inputDecoration(
                    label: 'Jenis transaksi',
                    icon: Icons.swap_vert_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'income',
                      child: Text('Pemasukan'),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Pengeluaran'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      type = value!;
                      category = activeCategories.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: inputDecoration(
                    label: 'Kategori',
                    icon: Icons.category_rounded,
                  ),
                  items: activeCategories
                      .map(
                        (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: inputDecoration(
                    label: 'Catatan',
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: saveTransaction,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Simpan Transaksi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<TransactionModel> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final data = await TransactionStorage.getTransactions();

    setState(() {
      transactions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadTransactions,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              IconButton(
                onPressed: loadTransactions,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Semua transaksi keuanganmu.',
            style: GoogleFonts.poppins(
              color: AppColors.grayText,
            ),
          ),
          const SizedBox(height: 20),
          if (transactions.isEmpty)
            const EmptyState(
              icon: Icons.history_rounded,
              title: 'Riwayat masih kosong',
              subtitle: 'Transaksi yang kamu simpan akan muncul di sini.',
            )
          else
            ...transactions.map(
                  (item) => TransactionItem(
                transaction: item,
                onDelete: () async {
                  await TransactionStorage.deleteTransaction(item.id);
                  loadTransactions();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List<FinanceTip> tips = [];

  @override
  void initState() {
    super.initState();
    loadTips();
  }

  Future<void> loadTips() async {
    final jsonString = await rootBundle.loadString('assets/finance_tips.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    setState(() {
      tips = jsonData.map((item) => FinanceTip.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 28),
        Text(
          'Tips Keuangan',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tips sederhana untuk mengatur uang mahasiswa.',
          style: GoogleFonts.poppins(
            color: AppColors.grayText,
          ),
        ),
        const SizedBox(height: 20),
        ...tips.map(
              (tip) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.lightGreen,
                  child: Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tip.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? AppColors.blue : AppColors.red;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${transaction.date}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
                if (transaction.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    transaction.note,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.grayText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 54,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}
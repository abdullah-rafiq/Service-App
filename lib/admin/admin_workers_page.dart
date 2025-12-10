import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/app_user.dart';
import 'package:flutter_application_1/admin/admin_worker_detail_page.dart';

class AdminWorkersPage extends StatelessWidget {
  const AdminWorkersPage({super.key});

  bool _isAdmin(AppUser? user) {
    return user != null && user.role == UserRole.admin;
  }

  @override
  Widget build(BuildContext context) {
    final current = FirebaseAuth.instance.currentUser;

    if (current == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in as admin to view this page.'),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(current.uid)
          .snapshots(),
      builder: (context, adminSnap) {
        if (adminSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!adminSnap.hasData || !adminSnap.data!.exists) {
          return const Center(child: Text('No admin profile found.'));
        }

        final adminUser = AppUser.fromMap(
          adminSnap.data!.id,
          adminSnap.data!.data()!,
        );

        if (!_isAdmin(adminUser)) {
          return const Center(child: Text('Only admins can access this page.'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('All workers'),
          ),
          backgroundColor: const Color(0xFFF6FBFF),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'provider')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text('No workers found.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final worker = AppUser.fromMap(doc.id, doc.data());

                  final name = (worker.name?.trim().isNotEmpty ?? false)
                      ? worker.name!.trim()
                      : 'Worker';

                  final verificationStatus =
                      doc.data()['verificationStatus'] as String? ?? 'none';

                  Color statusColor;
                  String statusLabel;
                  switch (verificationStatus) {
                    case 'approved':
                      statusColor = Colors.green;
                      statusLabel = 'Approved';
                      break;
                    case 'pending':
                      statusColor = Colors.orange;
                      statusLabel = 'Pending';
                      break;
                    case 'rejected':
                      statusColor = Colors.redAccent;
                      statusLabel = 'Rejected';
                      break;
                    default:
                      statusColor = Colors.blueGrey;
                      statusLabel = 'Not submitted';
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminWorkerDetailPage(worker: worker),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${worker.id}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phone: ${worker.phone ?? '-'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${worker.status}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          if (verificationStatus == 'pending')
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    label: const Text('Reject'),
                                    onPressed: () async {
                                      await _rejectWorker(context, worker.id);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approve'),
                                    onPressed: () async {
                                      await _approveWorker(context, worker.id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

Future<void> _approveWorker(BuildContext context, String workerId) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(workerId).update({
      'verified': true,
      'verificationStatus': 'approved',
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker approved successfully.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not approve worker: $e')),
      );
    }
  }
}

Future<void> _rejectWorker(BuildContext context, String workerId) async {
  final controller = TextEditingController();

  final reason = await showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Reject worker'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      );
    },
  );

  if (reason == null) return;

  try {
    await FirebaseFirestore.instance.collection('users').doc(workerId).update({
      'verificationStatus': 'rejected',
      'verificationReason': reason.isEmpty ? null : reason,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worker rejected.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reject worker: $e')),
      );
    }
  }
}

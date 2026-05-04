import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onboarding/onboarding.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:shared/shared.dart';

enum TimeType { start, close }

class DispatcherOnboardingPage extends StatefulWidget {
  const DispatcherOnboardingPage({super.key});

  @override
  State<DispatcherOnboardingPage> createState() =>
      _DispatcherOnboardingPageState();
}

class _DispatcherOnboardingPageState extends State<DispatcherOnboardingPage> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _cacController = TextEditingController();

  PhoneNumber? _phoneNumber;
  AddressDto? _selectedAddress;

  WorkingHours _workingHours = WorkingHours.defaultSchedule;

  @override
  void dispose() {
    _companyNameController.dispose();
    _cacController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true || _selectedAddress == null) {
      return;
    }

    context.read<OnboardingBloc>().add(
      OnboardingEvent.saveDispatcherOnboarding(
        companyName: _companyNameController.text,
        phoneNumber: _phoneNumber?.completeNumber ?? '',
        address: _selectedAddress!.address,
        cac: _cacController.text,
        workingHours: _workingHours,
      ),
    );

    // Navigate to complete onboarding page
    context.push(OnboardingRoutes.completeOnboarding);
  }

  Future<void> _selectTime(String day, TimeType type) async {
    final currentConfig = _workingHours.getDayConfig(day) ?? const DayConfig(start: '07:00', close: '19:00');
    final timeStr = type == TimeType.start ? currentConfig.start : currentConfig.close;
    final current = timeStr.split(':');
    
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(current[0]), minute: int.parse(current[1])),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      
      final newDayConfig = type == TimeType.start 
          ? currentConfig.copyWith(start: formattedTime)
          : currentConfig.copyWith(close: formattedTime);

      // Validation: Start must be before close
      if (newDayConfig.start.compareTo(newDayConfig.close) >= 0) {
        if (!mounted) return;
        context.toast.showToast(
          'Start time must be before closing time.',
          type: ToastType.error,
        );
        return;
      }

      setState(() {
        _workingHours = _workingHours.setDayConfig(day, newDayConfig);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, onboardingState) {
        return LogistixAuthScaffold(
          header: Container(
            padding: const EdgeInsets.all(BootstrapSpacing.lg),
            decoration: BoxDecoration(
              color: LogistixColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              size: 40,
              color: LogistixColors.primary,
            ),
          ),
          title: 'Company Profile',
          subtitle:
              'Provide your company details and operating schedule.',
          onBack: () => context.pop(),
          footer: BootstrapButton(
            label: 'Complete Setup',
            isLoading: onboardingState.status == OnboardingStatus.loading,
            onPressed: _submitOnboarding,
          ),
          children: [
            BootstrapCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PhoneTextField(
                      initialCountryCode: 'ng',
                      onChanged: (value) => _phoneNumber = value,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(LucideIcons.phone),
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    BootstrapTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: LucideIcons.building,
                      validator: FormBuilderValidators.required(),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    DropdownSearch<AddressDto>(
                      items: (String filter, _) async {
                        final cubit = context.read<AddressCubit>();
                        final results = await cubit.fetchAddresses(filter);

                        if (filter.isNotEmpty &&
                            !results.any((e) => e.address == filter)) {
                          return [...results, AddressDto(address: filter)];
                        }
                        return results;
                      },
                      itemAsString: (item) => item.address,
                      compareFn: EqualityFilter<AddressDto>(
                        (state) => state.address,
                      ).call,
                      selectedItem: _selectedAddress,
                      onChanged: (address) {
                        setState(() => _selectedAddress = address);
                      },
                      suffixProps: const DropdownSuffixProps(
                        clearButtonProps: ClearButtonProps(isVisible: true),
                        dropdownButtonProps: DropdownButtonProps(
                          isVisible: false,
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: const InputDecoration(
                          labelText: 'Company Address',
                          hintText: 'Search address...',
                          prefixIcon: Icon(LucideIcons.mapPin),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        loadingBuilder: (_, __) {
                          return const BootstrapLoadingIndicator();
                        },
                        searchFieldProps: const TextFieldProps(
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Start typing address...',
                            prefixIcon: Icon(LucideIcons.search),
                          ),
                        ),
                      ),
                      validator: (address) {
                        return address == null
                            ? 'Please select your address'
                            : null;
                      },
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    BootstrapTextField(
                      controller: _cacController,
                      label: 'CAC Reg Number',
                      icon: LucideIcons.badgeCheck,
                      hintText: 'RC123456 or BN123456',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.match(
                          RegExp(r'^(RC|BN)[0-9]{6,7}$'),
                          errorText: 'Invalid CAC (RC/BN + 6-7 digits)',
                        ),
                      ]),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: BootstrapSpacing.xl),
                    Text(
                      'Operating Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.sm),
                    Text(
                      'Set when your riders are available for dispatch.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: BootstrapSpacing.md),
                    ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                      final config = _workingHours.getDayConfig(day);
                      final isActive = config != null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: BootstrapSpacing.sm),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isActive,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _workingHours = _workingHours.setDayConfig(day, const DayConfig(start: '07:00', close: '19:00'));
                                        } else {
                                          _workingHours = _workingHours.setDayConfig(day, null);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      day.substring(0, 3),
                                      style: TextStyle(
                                        color: isActive ? null : Colors.grey,
                                        fontWeight: isActive ? FontWeight.w600 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive) ...[
                              const Spacer(),
                              BootstrapButton(
                                type: BootstrapButtonType.text,
                                onPressed: () => _selectTime(day, TimeType.start),
                                label: config.start,
                                padding: EdgeInsets.zero,
                              ),
                              Text(' – ', style: Theme.of(context).textTheme.bodyLarge),
                              BootstrapButton(
                                type: BootstrapButtonType.text,
                                onPressed: () => _selectTime(day, TimeType.close),
                                label: config.close,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

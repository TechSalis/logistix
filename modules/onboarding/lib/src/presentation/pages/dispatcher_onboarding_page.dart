import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_bloc.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_event.dart';
import 'package:onboarding/src/presentation/bloc/onboarding_state.dart';
import 'package:phone_text_field/phone_text_field.dart';
import 'package:shared/shared.dart';

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

  @override
  void dispose() {
    _companyNameController.dispose();
    _cacController.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<OnboardingBloc>().add(
      OnboardingEvent.submitDispatcherOnboarding(
        companyName: _companyNameController.text,
        phoneNumber: _phoneNumber?.completeNumber ?? '',
        address: _selectedAddress!.address,
        cac: _cacController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          context.go(ModuleRoutePaths.dispatcher);
        } else if (state.status == OnboardingStatus.error) {
          context.toast.showToast(
            state.message ?? 'An error occurred',
            type: ToastType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Company Information')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Complete Your Company Profile',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'We need some information to set up your dispatcher account',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: LogistixColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: FormBuilderValidators.required(),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              PhoneTextField(
                initialCountryCode: 'ng',
                onChanged: (value) => _phoneNumber = value,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
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
                  dropdownButtonProps: DropdownButtonProps(isVisible: false),
                ),
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Company Address',
                    hintText: 'Search address...',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  loadingBuilder: (_, _) => const LogistixLoadingIndicator(),
                  searchFieldProps: const TextFieldProps(
                    autofocus: true,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: 'Start typing address...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                validator: (address) {
                  return address == null ? 'Please select your address' : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cacController,
                decoration: const InputDecoration(
                  labelText: 'CAC Reg No',
                  prefixIcon: Icon(Icons.verified_outlined),
                  hintText: 'RC123456 or BN123456',
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.match(
                    RegExp(r'^(RC|BN)[0-9]{6,7}$'),
                    errorText:
                        'Invalid CAC Number (RC/BN followed by 6-7 digits)',
                  ),
                ]),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 32),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  final isLoading = state.status == OnboardingStatus.loading;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitOnboarding,
                    child: isLoading
                        ? const LogistixInlineLoader()
                        : const Text('Complete Setup'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

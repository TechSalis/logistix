import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:onboarding/onboarding.dart';
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
    if (_formKey.currentState?.validate() != true || _selectedAddress == null) {
      return;
    }

    context.read<OnboardingBloc>().add(
          OnboardingEvent.saveDispatcherOnboarding(
            companyName: _companyNameController.text,
            phoneNumber: _phoneNumber?.completeNumber ?? '',
            address: _selectedAddress!.address,
            cac: _cacController.text,
          ),
        );
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
              Icons.admin_panel_settings_rounded,
              size: 40,
              color: LogistixColors.primary,
            ),
          ),
          title: 'Company Profile',
          subtitle:
              'Provide your company details to set up your dispatcher account.',
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
                  children: [
                    PhoneTextField(
                      initialCountryCode: 'ng',
                      onChanged: (value) => _phoneNumber = value,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    BootstrapTextField(
                      controller: _companyNameController,
                      label: 'Company Name',
                      icon: Icons.business_rounded,
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
                        loadingBuilder: (_, __) =>
                            const BootstrapLoadingIndicator(),
                        searchFieldProps: const TextFieldProps(
                          autofocus: true,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: 'Start typing address...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      validator: (address) =>
                          address == null ? 'Please select your address' : null,
                    ),
                    const SizedBox(height: BootstrapSpacing.lg),
                    BootstrapTextField(
                      controller: _cacController,
                      label: 'CAC Reg Number',
                      icon: Icons.verified_rounded,
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

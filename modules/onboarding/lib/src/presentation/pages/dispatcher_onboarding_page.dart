import 'package:bootstrap/services/equality_filter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LogistixColors.primary.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LogistixSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: LogistixSpacing.xs),
                        Center(
                              child: Container(
                                padding: const EdgeInsets.all(
                                  LogistixSpacing.lg,
                                ),
                                decoration: BoxDecoration(
                                  color: LogistixColors.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 40,
                                  color: LogistixColors.primary,
                                ),
                              ),
                            )
                            .animate()
                            .fade(duration: 350.ms)
                            .scale(
                              begin: const Offset(0.85, 0.85),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: LogistixSpacing.lg),
                        Text(
                          'Company Profile',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineSmall?.bold.copyWith(
                            color: LogistixColors.text,
                          ),
                        ).animate(delay: 80.ms).fade().slideY(begin: 0.12),
                        const SizedBox(height: LogistixSpacing.xs),
                        Text(
                          'Provide your organization details to set up your dispatcher account.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: LogistixColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: LogistixSpacing.xxl),
                        LogistixCard(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LogistixTextField(
                                  controller: _companyNameController,
                                  label: 'Company Name',
                                  icon: Icons.business_rounded,
                                  validator: FormBuilderValidators.required(),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: LogistixSpacing.lg),
                                PhoneTextField(
                                  initialCountryCode: 'ng',
                                  onChanged: (value) => _phoneNumber = value,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                ),
                                const SizedBox(height: LogistixSpacing.lg),
                                DropdownSearch<AddressDto>(
                                  items: (String filter, _) async {
                                    final cubit = context.read<AddressCubit>();
                                    final results = await cubit.fetchAddresses(
                                      filter,
                                    );

                                    if (filter.isNotEmpty &&
                                        !results.any(
                                          (e) => e.address == filter,
                                        )) {
                                      return [
                                        ...results,
                                        AddressDto(address: filter),
                                      ];
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
                                    clearButtonProps: ClearButtonProps(
                                      isVisible: true,
                                    ),
                                    dropdownButtonProps: DropdownButtonProps(
                                      isVisible: false,
                                    ),
                                  ),
                                  decoratorProps: const DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: 'Company Address',
                                      hintText: 'Search address...',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                      ),
                                    ),
                                  ),
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    loadingBuilder: (_, _) =>
                                        const LogistixLoadingIndicator(),
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
                                    return address == null
                                        ? 'Please select your address'
                                        : null;
                                  },
                                ),
                                const SizedBox(height: LogistixSpacing.lg),
                                LogistixTextField(
                                  controller: _cacController,
                                  label: 'CAC Reg Number',
                                  icon: Icons.verified_rounded,
                                  hintText: 'RC123456 or BN123456',
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.match(
                                      RegExp(r'^(RC|BN)[0-9]{6,7}$'),
                                      errorText:
                                          'Invalid CAC (RC/BN + 6-7 digits)',
                                    ),
                                  ]),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: LogistixSpacing.xl),
                        BlocBuilder<OnboardingBloc, OnboardingState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == OnboardingStatus.loading;

                            return LogistixButton(
                              label: 'Complete Setup',
                              isLoading: isLoading,
                              onPressed: _submitOnboarding,
                            );
                          },
                        ),
                        const SizedBox(height: LogistixSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

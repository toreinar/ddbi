/**
 * Oracle import library.
 *
 * Part of the D DBI project.
 *
 * Version:
 *	Oracle 10g revision 2
 *
 *	Import library version 0.03
 *
 * Authors: The D DBI project
 *
 * Copyright: BSD license
 */
module dbi.oracle.imp.nzerror;

/**
 * Errors - when an error is added here, a message corresponding to the
 * error number must be added to the message file.
 * New errors must be assigned numbers, otherwise the compiler can assign any
 * value that it wants, which may lead to invalid error numbers being generated.
 * The number range currently assigned to the OSS is 28750 - 29249
 * New number range 43000 - 43499
 */
enum nzerror {
	NZERROR_OK			= 0,		///
	NZERROR_GENERIC			= 28750,	/// A catchall for errors.
	NZERROR_NO_MEMORY		= 28751,	/// No more memory.
	NZERROR_DATA_SOURCE_INIT_FAILED	= 28752,	/// Failed to init data source.
	NZERROR_DATA_SOURCE_TERM_FAILED	= 28753,	/// Failed to terminate data source.
	NZERROR_OBJECT_STORE_FAILED	= 28754,	/// Store object in data source failed.
	NZERROR_OBJECT_GET_FAILED	= 28755,	/// Failed to obtain object from data source.
	NZERROR_MEMORY_ALLOC_FAILED	= 28756,	/// Callback failed to allocate memory.
	NZERROR_MEMORY_ALLOC_0_BYTES	= 28757,	/// Attempted to ask for 0 bytes of memory.
	NZERROR_MEMORY_FREE_FAILED	= 28758,	/// Callback failed to free memory.
	NZERROR_FILE_OPEN_FAILED	= 28759,	/// Open of file failed.
	NZERROR_LIST_CREATION_FAILED	= 28760,	/// Creation of list failed.
	NZERROR_NO_ELEMENT		= 28761,	/// No list element found.
	NZERROR_ELEMENT_ADD_FAILED	= 28762,	/// Addition of list element failed.
	NZERROR_PARAMETER_BAD_TYPE	= 28763,	/// Retrieval of an unknown parameter type.
	NZERROR_PARAMETER_RETRIEVAL	= 28764,	/// Retrieval of parameter failed.
	NZERROR_NO_LIST			= 28765,	/// Data method list does not exist.
	NZERROR_TERMINATE_FAIL		= 28766,	/// Failed to terminate.
	NZERROR_BAD_VERSION_NUMBER	= 28767,	/// Bad version number.
	NZERROR_BAD_MAGIC_NUMBER	= 28768,	/// Bad magic number.
	NZERROR_METHOD_NOT_FOUND	= 28769,	/// Data retrieval method specified does not exist.
	NZERROR_ALREADY_INITIALIZED	= 28770,	/// The data source is already initialized.
	NZERROR_NOT_INITIALIZED		= 28771,	/// The data source is not initialized.
	NZERROR_BAD_FILE_ID		= 28772,	/// File ID is bad.
	NZERROR_WRITE_MAGIC_VERSION	= 28773,	/// Failed to write magic and version.
	NZERROR_FILE_WRITE_FAILED	= 28774,	/// Failed to write to file.
	NZERROR_FILE_CLOSE_FAILED	= 28775,	/// Failed to close file.
	NZERROR_OUTPUT_BUFFER_TOO_SMALL	= 28776,	/// The buffer supplied by the caller is too small.
	NZERROR_BINDING_CREATION_FAILED	= 28777,	/// NL failed in creating a binding.
	NZERROR_PARAMETER_MALFORMED	= 28778,	/// A parameter was in a bad format.
	NZERROR_PARAMETER_NO_METHOD	= 28779,	/// No method was specified for a data type.
	NZERROR_BAD_PARAMETER_METHOD	= 28780,	/// Illegal method for data type.
	NZERROR_PARAMETER_NO_DATA	= 28781,	/// No method specified when required.
	NZERROR_NOT_ALLOCATED		= 28782,	/// Data source is not allocated.
	NZERROR_INVALID_PARAMETER	= 28783,	/// Invalid parameter name.
	NZERROR_FILE_NAME_TRANSLATION	= 28784,	/// Could not translate OSD file name.
	NZERROR_NO_SUCH_PARAMETER	= 28785,	/// Selected parameter is non-existent.
	NZERROR_DECRYPT_FAILED		= 28786,	/// Encrypted private key decryption failure.
	NZERROR_ENCRYPT_FAILED		= 28787,	/// Private key encryption failed.
	NZERROR_INVALID_INPUT		= 28788,	/// Incorrect input or unknown error.
	NZERROR_NAME_TYPE_NOT_FOUND	= 28789,	/// Type of name requested is not available.
	NZERROR_NLS_STRING_OPEN_FAILED	= 28790,	/// Failure to generate an NLS string.
	NZERROR_CERTIFICATE_VERIFY	= 28791,	/// Failed to verify a certificate.
	NZERROR_OCI_PLSQL_FAILED	= 28792,	/// An OCI call to process some plsql failed.
	NZERROR_OCI_BIND_FAILED		= 28793,	/// An OCI call to bind an internal var. failed.
	NZERROR_ATTRIBUTE_INIT		= 28794,	/// Failed to init role retrieval.
	NZERROR_ATTRIBUTE_FINISH_FAILED	= 28795,	/// Did not complete role retrieval.
	NZERROR_UNSUPPORTED_METHOD	= 28796,	/// Data method specified not supported.
	NZERROR_INVALID_KEY_DATA_TYPE	= 28797,	/// Invalid data type specified for key.
	NZEROR_BIND_SUBKEY_COUNT	= 28798,	/// Number of sub-keys to bind does not match count in initialized key.
	NZERROR_AUTH_SHARED_MEMORY	= 28799,	/// Failed to retreieve authentication information from the shared memory.
	NZERROR_RIO_OPEN		= 28800,	/// RIO Open Failed.
	NZERROR_RIO_OBJECT_TYPE		= 28801,	/// RIO object type invalid.
	NZERROR_RIO_MODE		= 28802,	/// RIO mode invalid.
	NZERROR_RIO_IO			= 28803,	/// RIO io set or number invalid.
	NZERROR_RIO_CLOSE		= 28804,	/// RIO close failed.
	NZERROR_RIO_RETRIEVE		= 28805,	/// RIO retrieve failed.
	NZERROR_RIO_STORE		= 28806,	/// RIO store failed.
	NZERROR_RIO_UPDATE		= 28807,	/// RIO update failed.
	NZERROR_RIO_INFO		= 28808,	/// RIO info failed.
	NZERROR_RIO_DELETE		= 28809,	/// RIO delete failed.
	NZERROR_KD_CREATE		= 28810,	/// Key descriptor create failed.
	NZERROR_RIO_ACCESS_DESCRIPTOR	= 28811,	/// Access descriptor invalid.
	NZERROR_RIO_RECORD		= 28812,	/// Record invalid.
	NZERROR_RIO_RECORD_TYPE		= 28813,	/// Record type and AD type not matched.
	NZERROR_PLSQL_ORACLE_TO_REAL	= 28814,	/// A number passed to PL/SQL could not be converted to real format.
	NZERROR_PLSQL_REAL_TO_ORACLE	= 28815,	/// A number in machine format could not be converted to Oracle format.
	NZERROR_TK_PLSQL_NO_PASSWORD	= 28816,	/// A password was not provided to a PL/SQL function.
	NZERROR_TK_PLSQL_GENERIC	= 28817,	/// A PL/SQL function returned an error.
	NZERROR_TK_PLSQL_NO_CONTEXT	= 28818,	/// The package context was not specified to a PL/SQL function.
	NZERROR_TK_PLSQL_NO_DIST_NAME	= 28819,	/// The user's distinguished name was not provided to a PL/SQL function.
	NZERROR_TK_PLSQL_NO_STATE	= 28820,	/// The state of either a signature or decryption/encryption was not provided.
	NZERROR_TK_PLSQL_NO_INPUT	= 28821,	/// An input buffer was specified to a PL/SQL function.
	NZERROR_TK_PLSQL_NO_SEED	= 28822,	/// No seed was specified to the PL/SQL seed initialization function.
	NZERROR_TK_PLSQL_NO_BYTES	= 28823,	/// Number of bytes was not specified to the PL/SQL random number generator.
	NZERROR_TK_INVALID_STATE	= 28824,	/// Invalid encryption/decryption/signature state passed.
	NZERROR_TK_PLSQL_NO_ENG_FUNC	= 28825,	/// No crypto engine function was passed in.
	NZERROR_TK_INV_ENG_FUNC		= 28826,	/// An invalid crypto engine function was passed in.
	NZERROR_TK_INV_CIPHR_TYPE	= 28827,	/// An invalid cipher type was passed in.
	NZERROR_TK_INV_IDENT_TYPE	= 28828,	/// An invalid identity type was specified.
	NZERROR_TK_PLSQL_NO_CIPHER_TYPE	= 28829,	/// No cipher type was specified.
	NZERROR_TK_PLSQL_NO_IDENT_TYPE	= 28830,	/// No identity type was specified.
	NZERROR_TK_PLSQL_NO_DATA_FMT	= 28831,	/// No data unit format was specified.
	NZERROR_TK_INV_DATA_FMT		= 28832,	/// Invalid data unit format was provided to function.
	NZERROR_TK_PLSQL_INSUFF_INFO	= 28833,	/// Not enough info (usually parameters) provided to a PL/SQL function.
	NZERROR_TK_PLSQL_BUF_TOO_SMALL	= 28834,	/// Buffer provided by PL/SQL is too small for data to be returned.
	NZERROR_TK_PLSQL_INV_IDENT_DESC	= 28835,	/// Identity descriptor not present or too small.
	NZERROR_TK_PLSQL_WALLET_NOTOPEN	= 28836,	/// Wallet has not been opened yet.
	NZERROR_TK_PLSQL_NO_WALLET	= 28837,	/// No wallet descriptor specified to PL/SQL function.
	NZERROR_TK_PLSQL_NO_IDENTITY	= 28838,	/// No identity descriptor specified to PL/SQL function.
	NZERROR_TK_PLSQL_NO_PERSONA	= 28839,	/// No persona descriptor was specified to PL/SQL function.
	NZERROR_TK_PLSQL_WALLET_OPEN	= 28840,	/// Wallet was already opened.
	NZERROR_UNSUPPORTED		= 28841,	/// Operation is not supported.
	NZERROR_FILE_BAD_PERMISSION	= 28842,	/// Bad file permission specified.
	NZERROR_FILE_OSD_ERROR		= 28843,	/// OSD error when opening file.
	NZERROR_NO_WALLET		= 28844,	/// Cert + privkey + tp files do not exist.
	NZERROR_NO_CERTIFICATE_ALERT	= 28845,	/// No certificate.
	NZERROR_NO_PRIVATE_KEY		= 28846,	/// No private-key.
	NZERROR_NO_CLEAR_PRIVATE_KEY_FILE = 28847,	/// No clear key-file.
	NZERROR_NO_ENCRYPTED_PRIVATE_KEY_FILE = 28848,	/// No encrypted priv key.
	NZERROR_NO_TRUSTPOINTS		= 28849,	/// No trustpoints.
	NZERROR_NO_CLEAR_TRUSTPOINT_FILE= 28850,	/// No clear trustpoints.
	NZERROR_NO_ENCRYPTED_TRUSTPOINT_FILE = 28851,	/// No encrypted trustpoints.
	NZERROR_BAD_PASSWORD		= 28852,	/// Bad password.
	NZERROR_INITIALIZATION_FAILED	= 28853,	/// Init failed or module loading failed.
	NZERROR_SSLMemoryErr		= 28854,	///
	NZERROR_SSLUnsupportedErr	= 28855,	///
	NZERROR_SSLOverflowErr		= 28856,	///
	NZERROR_SSLUnknownErr		= 28857,	///
	NZERROR_SSLProtocolErr		= 28858,	///
	NZERROR_SSLNegotiationErr	= 28859,	///
	NZERROR_SSLFatalAlert		= 28860,	///
	NZERROR_SSLWouldBlockErr	= 28861,	///
	NZERROR_SSLIOErr		= 28862,	///
	NZERROR_SSLSessionNotFoundErr	= 28863,	///
	NZERROR_SSLConnectionClosedGraceful = 28864,	///
	NZERROR_SSLConnectionClosedError= 28865,	///
	NZERROR_ASNBadEncodingErr	= 28866,	///
	NZERROR_ASNIntegerTooBigErr	= 28867,	///
	NZERROR_X509CertChainInvalidErr	= 28868,	///
	NZERROR_X509CertExpiredErr	= 28869,	///
	NZERROR_X509NamesNotEqualErr	= 28870,	///
	NZERROR_X509CertChainIncompleteErr = 28871,	///
	NZERROR_X509DataNotFoundErr	= 28872,	///
	NZERROR_SSLBadParameterErr	= 28873,	///
	NZERROR_SSLIOClosedOverrideGoodbyeKiss = 28874,	///
	NZERROR_X509MozillaSGCErr	=  28875,	///
	NZERROR_X509IESGCErr		=  28876,	///
	NZERROR_ImproperServerCredentials = 28877,	///
	NZERROR_ImproperClientCredentials = 28878,	///
	NZERROR_NoProtocolSideSet	= 28879,	///
	NZERROR_setPersonaFailed	= 28880,	///
	NZERROR_setCertFailed		= 28881,	///
	NZERROR_setVKeyFailed		= 28882,	///
	NZERROR_setTPFailed		= 28883,	///
	NZERROR_BadCipherSuite		= 28884,	///
	NZERROR_NoKeyPairForKeyUsage	= 28885,	///
	NZERROR_EntrustLoginFailed	= 28890,	///
	NZERROR_EntrustGetInfoFailed	= 28891,	///
	NZERROR_EntrustLoadCertificateFailed = 28892,	///
	NZERROR_EntrustGetNameFailed	= 28893,	///
	NZERROR_CertNotInstalled	= 29000,	///
	NZERROR_ServerDNMisMatched	= 29002,	///
	NZERROR_ServerDNMisConfigured	= 29003,	///
	NZERROR_CIC_ERR_SSL_ALERT_CB_FAILURE = 29004,	///
	NZERROR_CIC_ERR_SSL_BAD_CERTIFICATE = 29005,	///
	NZERROR_CIC_ERR_SSL_BAD_CERTIFICATE_REQUEST = 29006, ///
	NZERROR_CIC_ERR_SSL_BAD_CLEAR_KEY_LEN = 29007,	///
	NZERROR_CIC_ERR_SSL_BAD_DHPARAM_KEY_LENGTH = 29008, ///
	NZERROR_CIC_ERR_SSL_BAD_ENCRYPTED_KEY_LEN = 29009, ///
	NZERROR_CIC_ERR_SSL_BAD_EXPORT_KEY_LENGTH = 29010, ///
	NZERROR_CIC_ERR_SSL_BAD_FINISHED_MESSAGE = 29011, ///
	NZERROR_CIC_ERR_SSL_BAD_KEY_ARG_LEN = 29012,	///
	NZERROR_CIC_ERR_SSL_BAD_MAC	= 29013,	///
	NZERROR_CIC_ERR_SSL_BAD_MAX_FRAGMENT_LENGTH_EXTENSION = 29014, ///
	NZERROR_CIC_ERR_SSL_BAD_MESSAGE_LENGTH = 29015,	///
	NZERROR_CIC_ERR_SSL_BAD_PKCS1_PADDING = 29016,	///
	NZERROR_CIC_ERR_SSL_BAD_PREMASTER_SECRET_LENGTH = 29017, ///
	NZERROR_CIC_ERR_SSL_BAD_PREMASTER_SECRET_VERSION = 29018, ///
	NZERROR_CIC_ERR_SSL_BAD_PROTOCOL_VERSION = 29019, ///
	NZERROR_CIC_ERR_SSL_BAD_RECORD_LENGTH = 29020,	///
	NZERROR_CIC_ERR_SSL_BAD_SECRET_KEY_LEN = 29021,	///
	NZERROR_CIC_ERR_SSL_BAD_SIDE	= 29022,	///
	NZERROR_CIC_ERR_SSL_BUFFERS_NOT_EMPTY = 29023,	///
	NZERROR_CIC_ERR_SSL_CERTIFICATE_VALIDATE_FAILED = 29024, ///
	NZERROR_CIC_ERR_SSL_CERT_CHECK_CALLBACK = 29025,///
	NZERROR_CIC_ERR_SSL_DECRYPT_FAILED = 29026,	///
	NZERROR_CIC_ERR_SSL_ENTROPY_COLLECTION = 29027,	///
	NZERROR_CIC_ERR_SSL_FAIL_SERVER_VERIFY = 29028,	///
	NZERROR_CIC_ERR_SSL_HANDSHAKE_ALREADY_COMPLETED = 29029, ///
	NZERROR_CIC_ERR_SSL_HANDSHAKE_REQUESTED = 29030,///
	NZERROR_CIC_ERR_SSL_HANDSHAKE_REQUIRED = 29031,	///
	NZERROR_CIC_ERR_SSL_INCOMPLETE_IDENTITY = 29032,///
	NZERROR_CIC_ERR_SSL_INVALID_PFX	= 29033,	///
	NZERROR_CIC_ERR_SSL_NEEDS_CIPHER_OR_CLIENTAUTH = 29034, ///
	NZERROR_CIC_ERR_SSL_NEEDS_PRNG	= 29035,	///
	NZERROR_CIC_ERR_SSL_NOT_SUPPORTED = 29036,	///
	NZERROR_CIC_ERR_SSL_NO_CERTIFICATE = 29037,	///
	NZERROR_CIC_ERR_SSL_NO_MATCHING_CERTIFICATES = 29038, ///
	NZERROR_CIC_ERR_SSL_NO_MATCHING_CIPHER_SUITES = 29039, ///
	NZERROR_CIC_ERR_SSL_NO_SUPPORTED_CIPHER_SUITES = 29040, ///
	NZERROR_CIC_ERR_SSL_NULL_CB	= 29041,	///
	NZERROR_CIC_ERR_SSL_READ_BUFFER_NOT_EMPTY = 29042, ///
	NZERROR_CIC_ERR_SSL_READ_REQUIRED = 29043,	///
	NZERROR_CIC_ERR_SSL_RENEGOTIATION_ALREADY_REQUESTED = 29044, ///
	NZERROR_CIC_ERR_SSL_RENEGOTIATION_REFUSED = 29045, ///
	NZERROR_CIC_ERR_SSL_RESUMABLE_SESSION = 29046,	///
	NZERROR_CIC_ERR_SSL_TLS_EXTENSION_MISMATCH = 29047, ///
	NZERROR_CIC_ERR_SSL_UNEXPECTED_MSG = 29048,	///
	NZERROR_CIC_ERR_SSL_UNKNOWN_RECORD = 29049,	///
	NZERROR_CIC_ERR_SSL_UNSUPPORTED_CLIENT_AUTH_MODE = 29050, ///
	NZERROR_CIC_ERR_SSL_UNSUPPORTED_PUBKEY_TYPE = 29051, ///
	NZERROR_CIC_ERR_SSL_WRITE_BUFFER_NOT_EMPTY = 29052, ///
	NZERROR_CIC_ERR_PKCS12_MISSING_ALG = 29053,	///
	NZERROR_CIC_ERR_PKCS_AUTH_FAILED= 29054,	///
	NZERROR_CIC_ERR_PKCS_BAD_CONTENT_TYPE = 29055,	///
	NZERROR_CIC_ERR_PKCS_BAD_INPUT	= 29056,	///
	NZERROR_CIC_ERR_PKCS_BAD_PADDING= 29057,	///
	NZERROR_CIC_ERR_PKCS_BAD_SN	= 29058,	///
	NZERROR_CIC_ERR_PKCS_BAD_SN_LENGTH = 29059,	///
	NZERROR_CIC_ERR_PKCS_BAD_VERSION= 29060,	///
	NZERROR_CIC_ERR_PKCS_BASE	= 29061,	///
	NZERROR_CIC_ERR_PKCS_FIELD_NOT_PRESENT = 29062,	///
	NZERROR_CIC_ERR_PKCS_NEED_CERTVAL = 29063,	///
	NZERROR_CIC_ERR_PKCS_NEED_PASSWORD = 29064,	///
	NZERROR_CIC_ERR_PKCS_NEED_PKC	= 29065,	///
	NZERROR_CIC_ERR_PKCS_NEED_PRV_KEY = 29066,	///
	NZERROR_CIC_ERR_PKCS_NEED_TRUSTED = 29067,	///
	NZERROR_CIC_ERR_PKCS_UNSUPPORTED_CERT_FORMAT = 29068, ///
	NZERROR_CIC_ERR_PKCS_UNSUP_PRVKEY_TYPE = 29069,	///
	NZERROR_CIC_ERR_CODING_BAD_PEM	= 29070,	///
	NZERROR_CIC_ERR_CODING_BASE	= 29071, 	///
	NZERROR_CIC_ERR_DER_BAD_ENCODING= 29072,	///
	NZERROR_CIC_ERR_DER_BAD_ENCODING_LENGTH = 29073,///
	NZERROR_CIC_ERR_DER_BASE	= 29074,	///
	NZERROR_CIC_ERR_DER_ELEMENT_TOO_LONG = 29075,	///
	NZERROR_CIC_ERR_DER_INDEFINITE_LENGTH = 29076,	///
	NZERROR_CIC_ERR_DER_NO_MORE_ELEMENTS = 29077,	///
	NZERROR_CIC_ERR_DER_OBJECT_TOO_LONG = 29078,	///
	NZERROR_CIC_ERR_DER_TAG_SIZE	= 29079,	///
	NZERROR_CIC_ERR_DER_TIME_OUT_OF_RANGE = 29080,	///
	NZERROR_CIC_ERR_DER_UNUSED_BITS_IN_BIT_STR = 29081, ///
	NZERROR_CIC_ERR_GENERAL_BASE	= 29082,	///
	NZERROR_CIC_ERR_HASH_BASE	= 29083,	///
	NZERROR_CIC_ERR_ILLEGAL_PARAM	= 29084,	///
	NZERROR_CIC_ERR_MEM_NOT_OURS	= 29085,	///
	NZERROR_CIC_ERR_MEM_OVERRUN	= 29086,	///
	NZERROR_CIC_ERR_MEM_UNDERRUN	= 29087,	///
	NZERROR_CIC_ERR_MEM_WAS_FREED	= 29088,	///
	NZERROR_CIC_ERR_NOT_FOUND	= 29090,	///
	NZERROR_CIC_ERR_NO_PTR		= 29091,	///
	NZERROR_CIC_ERR_TIMEOUT		= 29092,	///
	NZERROR_CIC_ERR_UNIT_MASK	= 29093,	///
	NZERROR_CIC_ERR_BAD_CTX		= 29094,	///
	NZERROR_CIC_ERR_BAD_INDEX	= 29095,	///
	NZERROR_CIC_ERR_BAD_LENGTH	= 29096,	///
	NZERROR_CIC_ERR_CODING_BAD_ENCODING = 29097,	///
	NZERROR_CIC_ERR_SSL_NO_CLIENT_AUTH_MODES = 29098, ///
	NZERROR_LOCKEYID_CREATE_FAILED	= 29100,	///
	NZERROR_P12_ADD_PVTKEY_FAILED	= 29101,	///
	NZERROR_P12_ADD_CERT_FAILED	= 29102,	///
	NZERROR_P12_WLT_CREATE_FAILED	= 29103,	///
	NZERROR_P12_ADD_CERTREQ_FAILED	= 29104,	///
	NZERROR_P12_WLT_EXP_FAILED	= 29105,	///
	NZERROR_P12_WLT_IMP_FAILED	= 29106,	///
	NZERROR_P12_CREATE_FAILED	= 29107,	///
	NZERROR_P12_DEST_FAILED		= 29107,	///
	NZERROR_P12_RAND_ERROR		= 29108, 	///
	NZERROR_P12_PVTKEY_CRT_FAILED	= 29109,	///
	NZERROR_P12_INVALID_BAG		= 29110,	///
	NZERROR_P12_INVALID_INDEX	= 29111,	///
	NZERROR_P12_GET_CERT_FAILED	= 29112,	///
	NZERROR_P12_GET_PVTKEY_FAILED	= 29113,	///
	NZERROR_P12_IMP_PVTKEY_FAILED	= 29114,	///
	NZERROR_P12_EXP_PVTKEY_FAILED	= 29115,	///
	NZERROR_P12_GET_ATTRIB_FAILED	= 29116,	///
	NZERROR_P12_ADD_ATTRIB_FAILED	= 29117,	///
	NZERROR_P12_CRT_ATTRIB_FAILED	= 29118,	///
	NZERROR_P12_IMP_CERT_FAILED	= 29119,	///
	NZERROR_P12_EXP_CERT_FAILED	= 29120,	///
	NZERROR_P12_ADD_SECRET_FAILED	= 29121,	///
	NZERROR_P12_ADD_PKCS11INFO_FAILED = 29122,	///
	NZERROR_P12_GET_PKCS11INFO_FAILED = 29123,	///
	NZERROR_P12_MULTIPLE_PKCS11_LIBNAME = 29124,	///
	NZERROR_P12_MULTIPLE_PKCS11_TOKENLABEL = 29125,	///
	NZERROR_P12_MULTIPLE_PKCS11_TOKENPASSPHRASE = 29126, ///
	NZERROR_P12_UNKNOWN_PKCS11INFO	= 29127,	///
	NZERROR_P12_PKCS11_LIBNAME_NOT_SET = 29128,	///
	NZERROR_P12_PKCS11_TOKENLABEL_NOT_SET = 29129,	///
	NZERROR_P12_PKCS11_TOKENPASSPHRASE_NOT_SET = 29130, ///
	NZERROR_P12_MULTIPLE_PKCS11_CERTLABEL = 29131,	///
	NZERROR_CIC_ERR_RANDOM		= 29135,	///
	NZERROR_CIC_ERR_SMALL_BUFFER	= 29136,	///
	NZERROR_CIC_ERR_SSL_BAD_CONTEXT	= 29137,	///
	NZERROR_MUTEX_INITIALIZE_FAILED	= 29138,	///
	NZERROR_MUTEX_DESTROY_FAILED	= 29139,	///
	NZERROR_BS_CERTOBJ_CREAT_FAILED	= 29140,	///
	NZERROR_BS_DER_IMP_FAILED	= 29141,	///
	NZERROR_DES_SELF_TEST_FAILED	= 29150,	///
	NZERROR_3DES_SELF_TEST_FAILED	= 29151,	///
	NZERROR_SHA_SELF_TEST_FAILED	= 29152,	///
	NZERROR_RSA_SELF_TEST_FAILED	= 29153,	///
	NZERROR_DRNG_SELF_TEST_FAILED	= 29154,	///
	NZERROR_CKEYPAIR_SELF_TEST_FAILED = 29155,	///
	NZERROR_CRNG_SELF_TEST_FAILED	= 29156,	///
	NZERROR_FIPS_PATHNAME_ERROR	= 29157,	///
	NZERROR_FIPS_LIB_OPEN_FAILED	= 29158,	///
	NZERROR_FIPS_LIB_READ_ERROR	= 29159,	///
	NZERROR_FIPS_LIB_DIFFERS	= 29160,	///
	NZERROR_DAC_SELF_TEST_FAILED	= 29161,	///
	NZERROR_NONFIPS_CIPHERSUITE	= 29162,	///
	NZERROR_VENDOR_NOT_SUPPORTED_FIPS_MODE = 29163,	///
	NZERROR_EXTERNAL_PKCS12_NOT_SUPPORTED_FIPS_MODE = 29164, ///
	NZERROR_AES_SELF_TEST_FAILED	= 29165,	///
	NZERROR_CRL_SIG_VERIFY_FAILED	= 29176,	/// CRL signature verification failed.
	NZERROR_CERT_NOT_IN_CRL		= 29177,	/// Cert is not in CRL - cert is not revoked.
	NZERROR_CERT_IN_CRL		= 29178,	/// Cert is in CRL - cert is revoked.
	NZERROR_CERT_IN_CRL_CHECK_FAILED= 29179,	/// Cert revocation check failed.
	NZERROR_INVALID_CERT_STATUS_PROTOCOL = 29180, 
	NZERROR_LDAP_OPEN_FAILED	= 29181,	/// ldap_open failed.
	NZERROR_LDAP_BIND_FAILED	= 29182,	/// ldap_bind failed.
	NZERROR_LDAP_SEARCH_FAILED	= 29183,	/// ldap_search failed.
	NZERROR_LDAP_RESULT_FAILED	= 29184,	/// ldap_result failed.
	NZERROR_LDAP_FIRSTATTR_FAILED	= 29185,	/// ldap_first_attribute failed.
	NZERROR_LDAP_GETVALUESLEN_FAILED= 29186,	/// ldap_get_values_len failed.
	NZERROR_LDAP_UNSUPPORTED_VALMEC = 29187,	/// Unsupported validation mechanism.
	NZERROR_LDAP_COUNT_ENTRIES_FAILED = 29188,	/// ldap_count_entries failed.
	NZERROR_LDAP_NO_ENTRY_FOUND	= 29189,	/// No entry found in OID.
	NZERROR_LDAP_MULTIPLE_ENTRIES_FOUND = 29190,	/// Multiple entries in OID.
	NZERROR_OID_INFO_NOT_SET	= 29191, 
	NZERROR_LDAP_VALMEC_NOT_SET	= 29192,	/// Validation mechanism not set in OID.
	NZERROR_CRLDP_NO_CRL_FOUND	= 29193,	/// No CRL found using CRLDP mechanism.
	NZERROR_CRL_NOT_IN_CACHE	= 29194,	/// No CRL found in the cache.
	NZERROR_CRL_EXPIRED		= 29195,	/// CRL nextUpdate time is in the past.
	NZERROR_DN_MATCH		= 29222,	/// For nztCompareDN.
	NZERROR_CERT_CHAIN_CREATION	= 29223,	/// Unable to create a cert chain with the existing TPs for the  cert to be installed.
	NZERROR_NO_MATCHING_CERT_REQ	= 29224,	/// No matching cert_req was  found the corresponding to the privatekey which matches the cert to be installed.
	NZERROR_CERT_ALREADY_INSTALLED	= 29225,	/// We are attempting to install a cert again into a persona which already has it installed.
	NZERROR_NO_MATCHING_PRIVATE_KEY	= 29226,	/// Could not find a matching persona-private(privatekey) in the Persona, for the given cert(public key).
	NZERROR_VALIDITY_EXPIRED	= 29227,	/// Certificate validity date expired.
	NZERROR_TK_BYTES_NEEDED		= 29228,	/// Couldn't determine # of bytes needed.
	NZERROR_TK_BAD_MAGIC_NUMBER	= 29229,	/// Magic number found in header does not match expected.
	NZERROR_TK_BAD_HEADER_LENGTH	= 29230,	/// Header length passed in not sufficient for message header.
	NZERROR_TK_CE_INIT		= 29231,	/// Crypto engine failed to initialize.
	NZERROR_TK_CE_KEYINIT		= 29232,	/// Crypto engine key initialization failed.
	NZERROR_TK_CE_ENCODE_KEY	= 29233,	/// Count not encode key object.
	NZERROR_TK_CE_DECODE_KEY	= 29234,	/// Could not decode key into object.
	NZERROR_TK_CE_GEYKEYINFO	= 29235,	/// Crypto engine failed to get key info.
	NZERROR_TK_SEED_RANDOM		= 29236,	/// Couldn't seed random number generator.
	NZERROR_TK_CE_ALGFINISH		= 29237,	/// Couldn't finish algorithm.
	NZERROR_TK_CE_ALGAPPLY		= 29238,	/// Couldn't apply algorithm to data.
	NZERROR_TK_CE_ALGINIT		= 29239,	/// Couldn't init CE for algorithm.
	NZERROR_TK_ALGORITHM		= 29240,	/// Have no idea what algorithm you want.
	NZERROR_TK_CANNOT_GROW		= 29241,	/// Cannot grow output buffer block.
	NZERROR_TK_KEYSIZE		= 29242,	/// Key not large enough for data.
	NZERROR_TK_KEYTYPE		= 29243,	/// Unknown key type.
	NZERROR_TK_PLSQL_NO_WRL		= 29244,	/// Wallet resource locator not specified to PL/SQL function.
	NZERROR_TK_CE_FUNC		= 29245,	/// Unknown crypto engine function.
	NZERROR_TK_TDU_FORMAT		= 29246,	/// Unknown TDU format.
	NZERROR_TK_NOTOPEN		= 29247,	/// Object must be open.
	NZERROR_TK_WRLTYPE		= 29248,	/// Bad WRL type.
	NZERROR_TK_CE_STATE		= 29249,	/// Bad state specified for the crypto engine.
	NZERROR_PKCS11_LIBRARY_NOT_FOUND= 43000,	/// PKCS #11 library not found.
	NZERROR_PKCS11_TOKEN_NOT_FOUND	= 43001,	/// Can't find token with given label.
	NZERROR_PKCS11_BAD_PASSPHRASE	= 43002,	/// Passphrase is incorrect/expired.
	NZERROR_PKCS11_GET_FUNC_LIST	= 43003,	/// C_GetFunctionList returned error.
	NZERROR_PKCS11_INITIALIZE	= 43004,	/// C_Initialize returned error.
	NZERROR_PKCS11_NO_TOKENS_PRESENT= 43005,	/// No tokens present.
	NZERROR_PKCS11_GET_SLOT_LIST	= 43006,	/// C_GetSlotList returned error.
	NZERROR_PKCS11_GET_TOKEN_INFO	= 43008,	/// C_GetTokenInfo returned error.
	NZERROR_PKCS11_SYMBOL_NOT_FOUND	= 43009,	/// Symbol not found in PKCS11 lib.
	NZERROR_PKCS11_TOKEN_LOGIN_FAILED = 43011,	/// Token login failed.
	NZERROR_PKCS11_CHANGE_PROVIDERS_ERROR = 43013,	/// Change providers error.
	NZERROR_PKCS11_GET_PRIVATE_KEY_ERROR = 43014,	/// Error trying to find private key on token.
	NZERROR_PKCS11_CREATE_KEYPAIR_ERROR = 43015,	/// Key pair gen error.
	NZERROR_PKCS11_WALLET_CONTAINS_P11_INFO = 43016,/// Wallet already contains pkcs11 info.
	NZERROR_PKCS11_NO_CERT_ON_TOKEN	= 43017,	/// No cert found on token.
	NZERROR_PKCS11_NO_USER_CERT_ON_TOKEN = 43018,	/// No user cert found on token.
	NZERROR_PKCS11_NO_CERT_ON_TOKEN_WITH_GIVEN_LABEL = 43019, ///No cert found on token with given certificate label.
	NZERROR_PKCS11_MULTIPLE_CERTS_ON_TOKEN_WITH_GIVEN_LABEL = 43020, ///Multiple certs found on token with given certificate label.
	NZERROR_PKCS11_CERT_WITH_LABEL_NOT_USER_CERT  = 43021, ///Cert with given cert is not a user cert because no corresponding pvt key found on token.
	NZERROR_BIND_SERVICE_ERROR	= 43050,	/// C_BindService returned error.
	NZERROR_CREATE_KEY_OBJ_ERROR	= 43051,	/// B_CreateKeyObject returned error.
	NZERROR_GET_CERT_FIELDS		= 43052,	/// C_GetCertFields returned error.
	NZERROR_CREATE_PKCS10_OBJECT	= 43053,	/// C_CreatePKCS10Object returned error.
	NZERROR_SET_PKCS10_FIELDS	= 43054,	/// C_SetPKCS10Fields returned error.
	NZERROR_SIGN_CERT_REQUEST	= 43055,	/// C_SignCertRequest returned error.
	NZERROR_GET_PKCS10_DER		= 43056,	/// C_GetPKCS10DER returned error.
	NZERROR_INITIALIZE_CERTC	= 43057,	/// C_InitializeCertC returned error.
	NZERROR_INSERT_PRIVATE_KEY	= 43058,	/// C_InsertPrivateKey returned error.
	NZERROR_RSA_ERROR		= 43059,	/// RSA error. See trace output.
	NZERROR_SLTSCTX_INIT_FAILED	= 43060,	/// sltsini() returned error.
	NZERROR_SLTSKYC_FAILED		= 43061,	/// sltskyc() returned error.
	NZERROR_SLTSCTX_TERM_FAILED	= 43062,	/// sltster() returned error.
	NZERROR_SLTSKYS_FAILED		= 43063,	/// sltskys() returned error.
	NZERROR_INVALID_HEADER_LENGTH	= 43070,	/// Bad sso header length.
	NZERROR_WALLET_CONTAINS_USER_CREDENTIALS = 43071, /// Wallet not empty.
	NZERROR_LAST_ERROR		= 43499,	/// Last available error.
	NZERROR_THIS_MUST_BE_LAST
}

/**
 * Macro to convert SSL errors to Oracle errors. As SSL errors are negative
 * and Oracle numbers are positive, the following needs to be done.
 * 1. The base error number, which is the highest, is added to the
 *    SSL error to get the index into the number range.
 * 2. The result is added to the base Oracle number to get the Oracle error.
 *
 * Bugs:
 *	This cannot work until we have SSL in D.
 */
nzerror NZERROR_SSL_TO_ORACLE (int ssl_error) {
	return nzerror.NZERROR_SSLUnknownErr;
//	return ssl_error == SSLNoErr ? nzerror.NZERROR_OK : cast(nzerror)(ssl_error - SSLMemoryErr + cast(size_t)nzerror.NZERROR_SSLMemoryErr);
}
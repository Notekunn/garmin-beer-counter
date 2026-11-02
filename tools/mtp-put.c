// Copies a file into GARMIN/Apps on a watch and verifies it by reading the folder back.
// mtp-sendfile cannot resolve the destination path on the Forerunner 165.
#include <libmtp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>

static LIBMTP_file_t *find(LIBMTP_file_t *f, const char *name) {
    for (; f; f = f->next) {
        if (f->filename && !strcasecmp(f->filename, name)) {
            return f;
        }
    }
    return NULL;
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "usage: mtp-put <local-file> <name-on-watch>\n");
        return 2;
    }
    struct stat st;
    if (stat(argv[1], &st)) {
        perror(argv[1]);
        return 2;
    }

    LIBMTP_raw_device_t *raw;
    int count;
    LIBMTP_Init();
    if (LIBMTP_Detect_Raw_Devices(&raw, &count) || count < 1) {
        fprintf(stderr, "no MTP device found\n");
        return 1;
    }
    LIBMTP_mtpdevice_t *dev = LIBMTP_Open_Raw_Device_Uncached(&raw[0]);
    if (!dev || LIBMTP_Get_Storage(dev, LIBMTP_STORAGE_SORTBY_NOTSORTED) || !dev->storage) {
        fprintf(stderr, "could not open device storage\n");
        return 1;
    }
    uint32_t storage = dev->storage->id;

    LIBMTP_file_t *garmin = find(LIBMTP_Get_Files_And_Folders(dev, storage, LIBMTP_FILES_AND_FOLDERS_ROOT), "GARMIN");
    LIBMTP_file_t *apps = garmin ? find(LIBMTP_Get_Files_And_Folders(dev, storage, garmin->item_id), "Apps") : NULL;
    if (!apps) {
        fprintf(stderr, "GARMIN/Apps not found\n");
        return 1;
    }
    uint32_t parent = apps->item_id;

    LIBMTP_file_t *old = find(LIBMTP_Get_Files_And_Folders(dev, storage, parent), argv[2]);
    if (old && LIBMTP_Delete_Object(dev, old->item_id)) {
        LIBMTP_Dump_Errorstack(dev);
        return 1;
    }

    LIBMTP_file_t *meta = LIBMTP_new_file_t();
    meta->filename = strdup(argv[2]);
    meta->filesize = st.st_size;
    meta->filetype = LIBMTP_FILETYPE_UNKNOWN;
    meta->parent_id = parent;
    meta->storage_id = storage;
    if (LIBMTP_Send_File_From_File(dev, argv[1], meta, NULL, NULL)) {
        LIBMTP_Dump_Errorstack(dev);
        return 1;
    }

    LIBMTP_file_t *sent = find(LIBMTP_Get_Files_And_Folders(dev, storage, parent), argv[2]);
    int ok = sent && (off_t)sent->filesize == st.st_size;
    printf("%s GARMIN/Apps/%s (%lld bytes)\n", ok ? "verified" : "VERIFY FAILED", argv[2], (long long)st.st_size);
    LIBMTP_Release_Device(dev);
    return ok ? 0 : 1;
}

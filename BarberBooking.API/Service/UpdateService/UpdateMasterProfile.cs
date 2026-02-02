using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateMasterProfile : IUpdateMasterProfile
    {
        public async Task UpdateAsync(MasterProfile masterProfile, DtoUpdateMasterProfile? dto)
        {
            var bio = !string.IsNullOrWhiteSpace(dto.Bio) ? dto.Bio : dto.Bio;
            masterProfile.UpdateBio(bio);
            var specialization = !string.IsNullOrWhiteSpace(dto.Specialization) ? dto.Specialization : dto.Specialization;
            masterProfile.UpdateSpecialization(specialization);
            var avatarUrl = !string.IsNullOrWhiteSpace(dto.AvatarUrl) ? dto.AvatarUrl : dto.AvatarUrl;
            masterProfile.UpdateAvatarUrl(avatarUrl);
        }
    }
}